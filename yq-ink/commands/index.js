import React, { useEffect, useMemo, useState } from "react";
import { Form, Field } from "react-final-form";
import { AppContext, Box, Color, Static, Text, useApp, useInput } from "ink";
import TextInput from "../components/TextInput";
import SelectInput from "../components/SelectInput";
import MultiSelectInput from "../components/MultiSelectInput";
import Switch from "../components/Switch";
import Error from "../components/Error";
import semver from "semver";
import fetch from "node-fetch";
import Spinner from "ink-spinner";
import glob from "glob";
import _, { first } from "lodash";
import yaml from "yaml";
import fs from "fs";
import { exec } from "child_process";

if (false) {
	console.warn = function (...args) {
		return;
	};

	console.error = function (...args) {
		return;
	};
}

const npmCache = {};
const checkPackage = (name) => {
	if (npmCache[name] === undefined) {
		return fetch(`https://api.npms.io/v2/package/${name}`)
			.then((response) => response.json())
			.then((json) => {
				npmCache[name] = json.code !== "NOT_FOUND";
				return npmCache[name];
			});
	}
	return npmCache[name];
};

const OPS = [
	{
		label: "Change version of infra profile",
		value: "infra",
	},
	{
		label: "Change version of addon-profile",
		value: "addon",
	},
	{
		label: "Add a new addon profile",
		value: "add-profile",
	},
];

const BLACKLIST_TAGS = ["latlng"];

function wait(ms) {
	return new Promise((resolve) => setTimeout(resolve, ms));
}

function executeCommand(command, file) {
	return new Promise((resolve) => {
		exec(`${command} ${file}`, async (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				return;
			}

			resolve();
		});
	});
}

/// CliForm
export default function CliForm() {
	const [activeField, setActiveField] = React.useState(0);
	const [submission, setSubmission] = React.useState();
	const { exit } = useApp();

	const [files, setFiles] = useState([]);
	const [initialized, setInitialized] = useState(false);
	const [data, setFormData] = useState({});
	const [tags, setTags] = useState({ options: {}, names: [] });
	const [filterCount, setFilters] = useState(0);
	const [filterOps, setFilterOps] = useState([]);
	const [filterStep, setFilterStep] = useState("pending");
	const [allStores, setAllStores] = useState([]);
	const [done, setDone] = useState(false);

	useInput((input) => {
		if (activeField === (filterCount + 1) * 2 + 1) {
			if (["a", "o"].includes(input)) {
				setFilterOps((state) => {
					return [...state, input === "a" ? "and" : "or"];
				});
				setFilters((state) => state + 1);
			}

			if (input === "c") {
				setFilterStep("continue");
			}
		}
	});

	useEffect(() => {
		async function init() {
			const files = glob.sync("*.yaml");
			setFiles(files);
			setInitialized(true);
			setFormData((data) => _.cloneDeep(_.set(data, "files", files)));
		}

		init();
	}, []);

	useEffect(() => {
		if (activeField === 1) {
			const files = data.files;

			if (!files) {
				exit();
			}

			const stores = files
				.map((file) => {
					const fileContent = fs.readFileSync(file, "utf8");
					return yaml.parse(fileContent);
				})
				.flat();

			setAllStores(stores);

			const names = _.uniq(
				stores.reduce((accumulator, store) => {
					const tags = Object.keys(store.tags);

					return accumulator.concat(tags);
				}, [])
			).filter((tag) => !BLACKLIST_TAGS.includes(tag));

			const options = names.reduce((accumulator, tag) => {
				accumulator[tag] = _.uniq(
					stores.map((store) => _.get(store, `tags.${tag}`))
				);
				return accumulator;
			}, {});

			setTags({ names, options });
		}
	}, [activeField, data]);

	const fields = useMemo(() => {
		const filterFields = Array.from({ length: filterCount + 1 })
			.map((__, index) => [
				{
					name: `filters.${index}.tag`,
					label: "Filter tag",
					Input: SelectInput,
					format: null, // prevents empty value from being ''
					inputConfig: {
						items: tags.names.map((tag) => ({ label: tag, value: tag })),
					},
				},
				{
					name: `filters.${index}.value`,
					label: "Filter value",
					Input: MultiSelectInput,
					format: null, // prevents empty value from being ''
					inputConfig: {
						items: (
							tags.options?.[_.get(data, `filters.${index}.tag`)] || []
						).map((option) => ({ label: option, value: option })),
					},
				},
			])
			.flat();

		return [
			{
				name: "files",
				label: "Files",
				Input: MultiSelectInput,
				format: null, // prevents empty value from being ''
				inputConfig: {
					items: files.map((file) => ({ label: file, value: file })),
				},
			},
			...filterFields,
			filterStep === "continue" && {
				name: "operation",
				label: "Operation",
				Input: SelectInput,
				format: null, // prevents empty value from being ''
				inputConfig: {
					items: OPS,
				},
			},
			["infra", "addon"].includes(data.operation) && {
				name: "newTag",
				label: "Select new tag",
				Input: TextInput,
				format: (value) =>
					value === undefined ? "" : value.replace(/[^0-9.]/g, ""),
				validate: (value) =>
					!value
						? "Required"
						: semver.valid(value)
						? undefined
						: "Invalid semantic version",
			},
		].filter(Boolean);
	}, [files, filterCount, tags, data, filterStep]);

	const affectedStores = useMemo(() => {
		return allStores.filter((store) => {
			const conditions = data?.filters?.map((filter) => {
        if (!filter.value) {
          return true;
        }

				return filter.value.includes(_.get(store, `tags.${filter.tag}`));
			});

			if (filterOps.length === 0) {
				return conditions?.[0] || false;
			}

			return filterOps.every((op, index, arr) => {
        let firstMod = [0, arr.length -1].includes(index) ?  0 : -1;
        let secondMod = [0, arr.length -1].includes(index) ?  1 : 0;

				if (op === "and") {
					return !!(conditions[index + firstMod] && conditions[index + secondMod]);
				}
				if (op === "or") {
          return !!(conditions[index + firstMod] || conditions[index + secondMod]);
				}
			});
		});
	}, [allStores, data]);

	useEffect(() => {
		async function terminate() {
			await wait(1000);
			exit();
		}

		async function submit() {
			const conditions = data.filters.map((filter, index) => {
				let includes = (filter?.value || []).map(val => `.tags.${filter.tag} == "${val}"`);
        const template = `${includes.join(' or ')}`

				if (filterOps[index / 2]) {
					return `${template} ${filterOps[index / 2]} `;
				}

				return template;
			});

			const operation = `profiles.[${
				data.operation === "infra" ? 0 : 1
			}].tag = "${data.newTag}"`;

			const executions = data.files.map((file) => {
				return executeCommand(
					`yq -i '[.[] | select(${conditions.join(" ")}).${operation}]'`,
					file
				);
			});

			await Promise.allSettled(executions);
			await wait(1000);
			setDone(true);
			exit();
		}

		const filtersComplete = data.filters?.every((filter) => !!filter.value);

		if (
			allStores.length > 0 &&
			affectedStores.length === 0 &&
			data.filters?.length > 0 &&
			filtersComplete
		) {
			terminate();
		}

		if (submission) {
			submit();
		}
	}, [submission, affectedStores, data]);

	if (submission) {
		return (
			<>
				<Text>
					Affected stores: {affectedStores.map((store) => store.name).join(",")}
				</Text>
				<Text>
					Operation:
					<Switch value={data.operation}>
						<Switch.Case value="infra">
							Update infrastructure profile to {data.newTag}
						</Switch.Case>
					</Switch>
					<Switch value={data.operation}>
						<Switch.Case value="addon">
							Update addon profile to {data.newTag}
						</Switch.Case>
					</Switch>
				</Text>
				<Text>{done ? "✅ Yaml files updated" : <Spinner />}</Text>
			</>
		);
	}

	function renderTagPrompt() {
		if (filterStep === "pending" && activeField === (filterCount + 1) * 2 + 1) {
			if (affectedStores.length === 0) {
				return <Text>Affected stores: None... Terminating</Text>;
			}

			return (
				<>
          <Text> </Text>
					<Text>
						<Text bold>Affected stores: </Text>
						{affectedStores.map((store) => store.name).join(",")}
					</Text>
					<Text>Add more filters ?</Text>
					<Text><Text bold>A</Text>(nd) <Text bold>O</Text>(r) <Text bold>C</Text>(onfirm)</Text>
				</>
			);
		}
	}


	if (!initialized) {
    return null;
	}

	return (
		<>
			<Form onSubmit={setSubmission} initialValues={{files: files}}>
				{({ handleSubmit, validating }) => (
					<Box flexDirection="column">
						{fields.map(
							(
								{
									name,
									label,
									placeholder,
									format,
									validate,
									Input,
									inputConfig,
								},
								index
							) => (
								<>
									<Field
										name={name}
										key={name}
										format={format}
										validate={validate}
									>
										{({ input, meta }) => (
											<Box flexDirection="column">
												<Box>
													<Text bold={activeField === index}>{label}: </Text>
													{activeField === index ? (
														<Input
															{...input}
															{...inputConfig}
															placeholder={placeholder}
															onChange={(...args) => {
																input.onChange(...args);
																setFormData((data) =>
																	_.cloneDeep(_.set(data, name, args[0]))
																);
															}}
															onSubmit={() => {
																if (meta.valid && !validating) {
																	setActiveField((value) => value + 1); // go to next field
																	if (
																		activeField === fields.length - 1 &&
																		filterStep !== "pending"
																	) {
																		// last field, so submit
																		handleSubmit();
																	}
																} else {
																	input.onBlur(); // mark as touched to show error
																}
															}}
														/>
													) : (
														(input.value && <Text>{Array.isArray(input.value) ? input.value.join(", ") : input.value}</Text>) ||
														(placeholder && <Color gray>{placeholder}</Color>)
													)}
													{validating && name === "name" && (
														<Box marginLeft={1}>
															<Color yellow>
																<Spinner type="dots" />
															</Color>
														</Box>
													)}
													{meta.invalid && meta.touched && (
														<Box marginLeft={2}>
															<Color red>✖</Color>
														</Box>
													)}
													{meta.valid && meta.touched && meta.inactive && (
														<Box marginLeft={2}>
															<Color green>✔</Color>
														</Box>
													)}
												</Box>
												{meta.error && meta.touched && (
													<Error>{meta.error}</Error>
												)}
											</Box>
										)}
									</Field>
									<Text bold>
										{name.includes("value")
											? filterOps[index / 2 - 1]?.toUpperCase?.()
											: null}
									</Text>
								</>
							)
						)}
					</Box>
				)}
			</Form>
			{renderTagPrompt()}
		</>
	);
}
