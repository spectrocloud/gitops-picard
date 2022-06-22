// modules are defined as an array
// [ module function, map of requires ]
//
// map of requires is short require name -> numeric require
//
// anything defined in a previous bundle is accessed via the
// orig method which is the require for previous bundles
parcelRequire = (function (modules, cache, entry, globalName) {
  // Save the require from previous bundle to this closure if any
  var previousRequire = typeof parcelRequire === 'function' && parcelRequire;
  var nodeRequire = typeof require === 'function' && require;

  function newRequire(name, jumped) {
    if (!cache[name]) {
      if (!modules[name]) {
        // if we cannot find the module within our internal map or
        // cache jump to the current global require ie. the last bundle
        // that was added to the page.
        var currentRequire = typeof parcelRequire === 'function' && parcelRequire;
        if (!jumped && currentRequire) {
          return currentRequire(name, true);
        }

        // If there are other bundles on this page the require from the
        // previous one is saved to 'previousRequire'. Repeat this as
        // many times as there are bundles until the module is found or
        // we exhaust the require chain.
        if (previousRequire) {
          return previousRequire(name, true);
        }

        // Try the node require function if it exists.
        if (nodeRequire && typeof name === 'string') {
          return nodeRequire(name);
        }

        var err = new Error('Cannot find module \'' + name + '\'');
        err.code = 'MODULE_NOT_FOUND';
        throw err;
      }

      localRequire.resolve = resolve;
      localRequire.cache = {};

      var module = cache[name] = new newRequire.Module(name);

      modules[name][0].call(module.exports, localRequire, module, module.exports, this);
    }

    return cache[name].exports;

    function localRequire(x){
      return newRequire(localRequire.resolve(x));
    }

    function resolve(x){
      return modules[name][1][x] || x;
    }
  }

  function Module(moduleName) {
    this.id = moduleName;
    this.bundle = newRequire;
    this.exports = {};
  }

  newRequire.isParcelRequire = true;
  newRequire.Module = Module;
  newRequire.modules = modules;
  newRequire.cache = cache;
  newRequire.parent = previousRequire;
  newRequire.register = function (id, exports) {
    modules[id] = [function (require, module) {
      module.exports = exports;
    }, {}];
  };

  var error;
  for (var i = 0; i < entry.length; i++) {
    try {
      newRequire(entry[i]);
    } catch (e) {
      // Save first error but execute all entries
      if (!error) {
        error = e;
      }
    }
  }

  if (entry.length) {
    // Expose entry point to Node, AMD or browser globals
    // Based on https://github.com/ForbesLindesay/umd/blob/master/template.js
    var mainExports = newRequire(entry[entry.length - 1]);

    // CommonJS
    if (typeof exports === "object" && typeof module !== "undefined") {
      module.exports = mainExports;

    // RequireJS
    } else if (typeof define === "function" && define.amd) {
     define(function () {
       return mainExports;
     });

    // <script>
    } else if (globalName) {
      this[globalName] = mainExports;
    }
  }

  // Override the current require with this new one
  parcelRequire = newRequire;

  if (error) {
    // throw error from earlier, _after updating parcelRequire_
    throw error;
  }

  return newRequire;
})({"../components/TextInput.js":[function(require,module,exports) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = TextInput;

var _react = _interopRequireDefault(require("react"));

var _inkTextInput = _interopRequireDefault(require("ink-text-input"));

const _excluded = ["onBlur", "onFocus"];

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutProperties(source, excluded) { if (source == null) return {}; var target = _objectWithoutPropertiesLoose(source, excluded); var key, i; if (Object.getOwnPropertySymbols) { var sourceSymbolKeys = Object.getOwnPropertySymbols(source); for (i = 0; i < sourceSymbolKeys.length; i++) { key = sourceSymbolKeys[i]; if (excluded.indexOf(key) >= 0) continue; if (!Object.prototype.propertyIsEnumerable.call(source, key)) continue; target[key] = source[key]; } } return target; }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function TextInput(_ref) {
  let {
    onBlur,
    onFocus
  } = _ref,
      props = _objectWithoutProperties(_ref, _excluded);

  _react.default.useEffect(() => {
    onFocus();
    return onBlur;
  }, [onFocus, onBlur]);

  return /*#__PURE__*/_react.default.createElement(_inkTextInput.default, _extends({}, props, {
    showCursor: true
  }));
}
},{}],"../components/SelectInput.js":[function(require,module,exports) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = SelectInput;

var _react = _interopRequireDefault(require("react"));

var _inkSelectInput = _interopRequireDefault(require("ink-select-input"));

const _excluded = ["onSubmit", "onBlur", "onChange", "onFocus"];

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutProperties(source, excluded) { if (source == null) return {}; var target = _objectWithoutPropertiesLoose(source, excluded); var key, i; if (Object.getOwnPropertySymbols) { var sourceSymbolKeys = Object.getOwnPropertySymbols(source); for (i = 0; i < sourceSymbolKeys.length; i++) { key = sourceSymbolKeys[i]; if (excluded.indexOf(key) >= 0) continue; if (!Object.prototype.propertyIsEnumerable.call(source, key)) continue; target[key] = source[key]; } } return target; }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function SelectInput(_ref) {
  let {
    onSubmit,
    onBlur,
    onChange,
    onFocus
  } = _ref,
      props = _objectWithoutProperties(_ref, _excluded);

  _react.default.useEffect(() => {
    onFocus();
    return onBlur;
  }, [onFocus, onBlur]);

  return /*#__PURE__*/_react.default.createElement(_inkSelectInput.default, _extends({}, props, {
    onSelect: ({
      value
    }) => {
      onChange(value);
      onSubmit();
    }
  }));
}
},{}],"../components/MultiSelectInput.js":[function(require,module,exports) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = SelectInput;

var _react = _interopRequireDefault(require("react"));

var _inkMultiSelect = _interopRequireDefault(require("ink-multi-select"));

const _excluded = ["onBlur", "onChange", "onFocus", "value"];

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

function _objectWithoutProperties(source, excluded) { if (source == null) return {}; var target = _objectWithoutPropertiesLoose(source, excluded); var key, i; if (Object.getOwnPropertySymbols) { var sourceSymbolKeys = Object.getOwnPropertySymbols(source); for (i = 0; i < sourceSymbolKeys.length; i++) { key = sourceSymbolKeys[i]; if (excluded.indexOf(key) >= 0) continue; if (!Object.prototype.propertyIsEnumerable.call(source, key)) continue; target[key] = source[key]; } } return target; }

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function SelectInput(_ref) {
  let {
    onBlur,
    onChange,
    onFocus,
    value = []
  } = _ref,
      props = _objectWithoutProperties(_ref, _excluded);

  _react.default.useEffect(() => {
    onFocus();
    return onBlur;
  }, [onFocus, onBlur]);

  return /*#__PURE__*/_react.default.createElement(_inkMultiSelect.default, _extends({}, props, {
    selected: value.map(value => ({
      label: value,
      value
    })),
    onSelect: ({
      value: v
    }) => onChange(value.concat(v)),
    onUnselect: ({
      value: v
    }) => onChange(value.filter(item => item !== v))
  }));
}
},{}],"../components/Switch/index.js":[function(require,module,exports) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = Switch;

var _react = _interopRequireWildcard(require("react"));

function _getRequireWildcardCache(nodeInterop) { if (typeof WeakMap !== "function") return null; var cacheBabelInterop = new WeakMap(); var cacheNodeInterop = new WeakMap(); return (_getRequireWildcardCache = function (nodeInterop) { return nodeInterop ? cacheNodeInterop : cacheBabelInterop; })(nodeInterop); }

function _interopRequireWildcard(obj, nodeInterop) { if (!nodeInterop && obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { default: obj }; } var cache = _getRequireWildcardCache(nodeInterop); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj.default = obj; if (cache) { cache.set(obj, newObj); } return newObj; }

const Context = (0, _react.createContext)();

function Switch({
  value,
  children
}) {
  return /*#__PURE__*/_react.default.createElement(Context.Provider, {
    value: value
  }, children);
}

function MultiCase({
  value,
  children
}) {
  const contextValue = (0, _react.useContext)(Context);

  if (Array.isArray(value) && value.includes(contextValue)) {
    return children || null;
  }

  return null;
}

function Case({
  value,
  children
}) {
  const contextValue = (0, _react.useContext)(Context);

  if (contextValue !== value) {
    return null;
  }

  return children || null;
}

Switch.Case = Case;
Switch.MultiCase = MultiCase;
},{}],"../components/Error.js":[function(require,module,exports) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = Error;

var _react = _interopRequireDefault(require("react"));

var _ink = require("ink");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function Error({
  children
}) {
  return /*#__PURE__*/_react.default.createElement(_ink.Box, null, /*#__PURE__*/_react.default.createElement(_ink.Color, {
    red: true
  }, children));
}
},{}],"index.js":[function(require,module,exports) {
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = CliForm;

var _react = _interopRequireWildcard(require("react"));

var _reactFinalForm = require("react-final-form");

var _ink = require("ink");

var _TextInput = _interopRequireDefault(require("../components/TextInput"));

var _SelectInput = _interopRequireDefault(require("../components/SelectInput"));

var _MultiSelectInput = _interopRequireDefault(require("../components/MultiSelectInput"));

var _Switch = _interopRequireDefault(require("../components/Switch"));

var _Error = _interopRequireDefault(require("../components/Error"));

var _semver = _interopRequireDefault(require("semver"));

var _nodeFetch = _interopRequireDefault(require("node-fetch"));

var _inkSpinner = _interopRequireDefault(require("ink-spinner"));

var _glob = _interopRequireDefault(require("glob"));

var _lodash = _interopRequireDefault(require("lodash"));

var _yaml = _interopRequireDefault(require("yaml"));

var _fs = _interopRequireDefault(require("fs"));

var _child_process = require("child_process");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _getRequireWildcardCache(nodeInterop) { if (typeof WeakMap !== "function") return null; var cacheBabelInterop = new WeakMap(); var cacheNodeInterop = new WeakMap(); return (_getRequireWildcardCache = function (nodeInterop) { return nodeInterop ? cacheNodeInterop : cacheBabelInterop; })(nodeInterop); }

function _interopRequireWildcard(obj, nodeInterop) { if (!nodeInterop && obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { default: obj }; } var cache = _getRequireWildcardCache(nodeInterop); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj.default = obj; if (cache) { cache.set(obj, newObj); } return newObj; }

function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }

if (true) {
  console.warn = function (...args) {
    return;
  };

  console.error = function (...args) {
    return;
  };
}

const npmCache = {};

const checkPackage = name => {
  if (npmCache[name] === undefined) {
    return (0, _nodeFetch.default)(`https://api.npms.io/v2/package/${name}`).then(response => response.json()).then(json => {
      npmCache[name] = json.code !== "NOT_FOUND";
      return npmCache[name];
    });
  }

  return npmCache[name];
};

const OPS = [{
  label: "Change version of infra profile",
  value: "infra"
}, {
  label: "Change version of addon-profile",
  value: "addon"
}, {
  label: "Add a new addon profile",
  value: "add-profile"
}];
const BLACKLIST_TAGS = ["latlng"];

function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function executeCommand(command, file) {
  return new Promise(resolve => {
    (0, _child_process.exec)(`${command} ${file}`, async (error, stdout, stderr) => {
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
} /// CliForm


function CliForm() {
  const [activeField, setActiveField] = _react.default.useState(0);

  const [submission, setSubmission] = _react.default.useState();

  const {
    exit
  } = (0, _ink.useApp)();
  const [files, setFiles] = (0, _react.useState)([]);
  const [initialized, setInitialized] = (0, _react.useState)(false);
  const [data, setFormData] = (0, _react.useState)({});
  const [tags, setTags] = (0, _react.useState)({
    options: {},
    names: []
  });
  const [filterCount, setFilters] = (0, _react.useState)(0);
  const [filterOps, setFilterOps] = (0, _react.useState)([]);
  const [filterStep, setFilterStep] = (0, _react.useState)("pending");
  const [allStores, setAllStores] = (0, _react.useState)([]);
  const [done, setDone] = (0, _react.useState)(false);
  (0, _ink.useInput)(input => {
    if (activeField === (filterCount + 1) * 2 + 1) {
      if (["a", "o"].includes(input)) {
        setFilterOps(state => {
          return [...state, input === "a" ? "and" : "or"];
        });
        setFilters(state => state + 1);
      }

      if (input === "c") {
        setFilterStep("continue");
      }
    }
  });
  (0, _react.useEffect)(() => {
    async function init() {
      const files = _glob.default.sync("*.yaml");

      setFiles(files);
      setInitialized(true);
      setFormData(data => _lodash.default.cloneDeep(_lodash.default.set(data, "files", files)));
    }

    init();
  }, []);
  (0, _react.useEffect)(() => {
    if (activeField === 1) {
      const files = data.files;

      if (!files) {
        exit();
      }

      const stores = files.map(file => {
        const fileContent = _fs.default.readFileSync(file, "utf8");

        return _yaml.default.parse(fileContent);
      }).flat();
      setAllStores(stores);

      const names = _lodash.default.uniq(stores.reduce((accumulator, store) => {
        const tags = Object.keys(store.tags);
        return accumulator.concat(tags);
      }, [])).filter(tag => !BLACKLIST_TAGS.includes(tag));

      const options = names.reduce((accumulator, tag) => {
        accumulator[tag] = _lodash.default.uniq(stores.map(store => _lodash.default.get(store, `tags.${tag}`)));
        return accumulator;
      }, {});
      setTags({
        names,
        options
      });
    }
  }, [activeField, data]);
  const fields = (0, _react.useMemo)(() => {
    const filterFields = Array.from({
      length: filterCount + 1
    }).map((__, index) => {
      var _tags$options;

      return [{
        name: `filters.${index}.tag`,
        label: "Filter tag",
        Input: _SelectInput.default,
        format: null,
        // prevents empty value from being ''
        inputConfig: {
          items: tags.names.map(tag => ({
            label: tag,
            value: tag
          }))
        }
      }, {
        name: `filters.${index}.value`,
        label: "Filter value",
        Input: _SelectInput.default,
        format: null,
        // prevents empty value from being ''
        inputConfig: {
          items: (((_tags$options = tags.options) === null || _tags$options === void 0 ? void 0 : _tags$options[_lodash.default.get(data, `filters.${index}.tag`)]) || []).map(option => ({
            label: option,
            value: option
          }))
        }
      }];
    }).flat();
    return [{
      name: "files",
      label: "Files",
      Input: _MultiSelectInput.default,
      format: null,
      // prevents empty value from being ''
      inputConfig: {
        items: files.map(file => ({
          label: file,
          value: file
        }))
      }
    }, ...filterFields, filterStep === "continue" && {
      name: "operation",
      label: "Operation",
      Input: _SelectInput.default,
      format: null,
      // prevents empty value from being ''
      inputConfig: {
        items: OPS
      }
    }, ["infra", "addon"].includes(data.operation) && {
      name: "newTag",
      label: "Select new tag",
      Input: _TextInput.default,
      format: value => value === undefined ? "" : value.replace(/[^0-9.]/g, ""),
      validate: value => !value ? "Required" : _semver.default.valid(value) ? undefined : "Invalid semantic version"
    }].filter(Boolean);
  }, [files, filterCount, tags, data, filterStep]);
  const affectedStores = (0, _react.useMemo)(() => {
    return allStores.filter(store => {
      var _data$filters;

      const conditions = data === null || data === void 0 ? void 0 : (_data$filters = data.filters) === null || _data$filters === void 0 ? void 0 : _data$filters.map(filter => {
        return _lodash.default.get(store, `tags.${filter.tag}`) === filter.value;
      });

      if (filterOps.length === 0) {
        return (conditions === null || conditions === void 0 ? void 0 : conditions[0]) || false;
      }

      return filterOps.every((op, index) => {
        if (op === "and") {
          return conditions[index] && conditions[index + 1];
        }

        if (op === "or") {
          return conditions[index] || conditions[index + 1];
        }
      });
    });
  }, [allStores, data]);
  (0, _react.useEffect)(() => {
    var _data$filters2, _data$filters3;

    async function terminate() {
      await wait(1000);
      exit();
    }

    async function submit() {
      const conditions = data.filters.map((filter, index) => {
        let out = `.tags.${filter.tag} == "${filter.value}"`;

        if (filterOps[index / 2]) {
          return `${out} ${filterOps[index / 2]} `;
        }

        return out;
      });
      const operation = `profiles.[${data.operation === "infra" ? 0 : 1}].tag = "${data.newTag}"`;
      const executions = data.files.map(file => {
        return executeCommand(`yq -i '[.[] | select(${conditions.join(" ")}).${operation}]'`, file);
      });
      await Promise.allSettled(executions);
      await wait(1000);
      setDone(true);
      exit();
    }

    const filtersComplete = (_data$filters2 = data.filters) === null || _data$filters2 === void 0 ? void 0 : _data$filters2.every(filter => !!filter.value);

    if (allStores.length > 0 && affectedStores.length === 0 && ((_data$filters3 = data.filters) === null || _data$filters3 === void 0 ? void 0 : _data$filters3.length) > 0 && filtersComplete) {
      terminate();
    }

    if (submission) {
      submit();
    }
  }, [submission, affectedStores, data]);

  if (submission) {
    return /*#__PURE__*/_react.default.createElement(_react.default.Fragment, null, /*#__PURE__*/_react.default.createElement(_ink.Text, null, "Affected stores: ", affectedStores.map(store => store.name).join(",")), /*#__PURE__*/_react.default.createElement(_ink.Text, null, "Operation:", /*#__PURE__*/_react.default.createElement(_Switch.default, {
      value: data.operation
    }, /*#__PURE__*/_react.default.createElement(_Switch.default.Case, {
      value: "infra"
    }, "Update infrastructure profile to ", data.newTag)), /*#__PURE__*/_react.default.createElement(_Switch.default, {
      value: data.operation
    }, /*#__PURE__*/_react.default.createElement(_Switch.default.Case, {
      value: "addon"
    }, "Update addon profile to ", data.newTag))), /*#__PURE__*/_react.default.createElement(_ink.Text, null, done ? "✅ Yaml files updated" : /*#__PURE__*/_react.default.createElement(_inkSpinner.default, null)));
  }

  function renderTagPrompt() {
    if (filterStep === "pending" && activeField === (filterCount + 1) * 2 + 1) {
      if (affectedStores.length === 0) {
        return /*#__PURE__*/_react.default.createElement(_ink.Text, null, "Affected stores: None... Terminating");
      }

      return /*#__PURE__*/_react.default.createElement(_react.default.Fragment, null, /*#__PURE__*/_react.default.createElement(_ink.Text, null, " "), /*#__PURE__*/_react.default.createElement(_ink.Text, null, /*#__PURE__*/_react.default.createElement(_ink.Text, {
        bold: true
      }, "Affected stores: "), affectedStores.map(store => store.name).join(",")), /*#__PURE__*/_react.default.createElement(_ink.Text, null, "Add more filters ?"), /*#__PURE__*/_react.default.createElement(_ink.Text, null, /*#__PURE__*/_react.default.createElement(_ink.Text, {
        bold: true
      }, "A"), "(nd) ", /*#__PURE__*/_react.default.createElement(_ink.Text, {
        bold: true
      }, "O"), "(r) ", /*#__PURE__*/_react.default.createElement(_ink.Text, {
        bold: true
      }, "C"), "(onfirm)"));
    }
  }

  if (!initialized) {
    return null;
  }

  return /*#__PURE__*/_react.default.createElement(_react.default.Fragment, null, /*#__PURE__*/_react.default.createElement(_reactFinalForm.Form, {
    onSubmit: setSubmission,
    initialValues: {
      files: files
    }
  }, ({
    handleSubmit,
    validating
  }) => /*#__PURE__*/_react.default.createElement(_ink.Box, {
    flexDirection: "column"
  }, fields.map(({
    name,
    label,
    placeholder,
    format,
    validate,
    Input,
    inputConfig
  }, index) => {
    var _filterOps, _filterOps$toUpperCas;

    return /*#__PURE__*/_react.default.createElement(_react.default.Fragment, null, /*#__PURE__*/_react.default.createElement(_reactFinalForm.Field, {
      name: name,
      key: name,
      format: format,
      validate: validate
    }, ({
      input,
      meta
    }) => /*#__PURE__*/_react.default.createElement(_ink.Box, {
      flexDirection: "column"
    }, /*#__PURE__*/_react.default.createElement(_ink.Box, null, /*#__PURE__*/_react.default.createElement(_ink.Text, {
      bold: activeField === index
    }, label, ": "), activeField === index ? /*#__PURE__*/_react.default.createElement(Input, _extends({}, input, inputConfig, {
      placeholder: placeholder,
      onChange: (...args) => {
        input.onChange(...args);
        setFormData(data => _lodash.default.cloneDeep(_lodash.default.set(data, name, args[0])));
      },
      onSubmit: () => {
        if (meta.valid && !validating) {
          setActiveField(value => value + 1); // go to next field

          if (activeField === fields.length - 1 && filterStep !== "pending") {
            // last field, so submit
            handleSubmit();
          }
        } else {
          input.onBlur(); // mark as touched to show error
        }
      }
    })) : input.value && /*#__PURE__*/_react.default.createElement(_ink.Text, null, Array.isArray(input.value) ? input.value.join(", ") : input.value) || placeholder && /*#__PURE__*/_react.default.createElement(_ink.Color, {
      gray: true
    }, placeholder), validating && name === "name" && /*#__PURE__*/_react.default.createElement(_ink.Box, {
      marginLeft: 1
    }, /*#__PURE__*/_react.default.createElement(_ink.Color, {
      yellow: true
    }, /*#__PURE__*/_react.default.createElement(_inkSpinner.default, {
      type: "dots"
    }))), meta.invalid && meta.touched && /*#__PURE__*/_react.default.createElement(_ink.Box, {
      marginLeft: 2
    }, /*#__PURE__*/_react.default.createElement(_ink.Color, {
      red: true
    }, "\u2716")), meta.valid && meta.touched && meta.inactive && /*#__PURE__*/_react.default.createElement(_ink.Box, {
      marginLeft: 2
    }, /*#__PURE__*/_react.default.createElement(_ink.Color, {
      green: true
    }, "\u2714"))), meta.error && meta.touched && /*#__PURE__*/_react.default.createElement(_Error.default, null, meta.error))), /*#__PURE__*/_react.default.createElement(_ink.Text, null, name.includes("value") ? (_filterOps = filterOps[index / 2 - 1]) === null || _filterOps === void 0 ? void 0 : (_filterOps$toUpperCas = _filterOps.toUpperCase) === null || _filterOps$toUpperCas === void 0 ? void 0 : _filterOps$toUpperCas.call(_filterOps) : null));
  }))), renderTagPrompt());
}
},{"../components/TextInput":"../components/TextInput.js","../components/SelectInput":"../components/SelectInput.js","../components/MultiSelectInput":"../components/MultiSelectInput.js","../components/Switch":"../components/Switch/index.js","../components/Error":"../components/Error.js"}]},{},["index.js"], null)
//# sourceMappingURL=/index.js.map