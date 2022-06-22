import React from 'react'
import InkMultiSelect from 'ink-multi-select'

export default function SelectInput({
	onBlur,
	onChange,
	onFocus,
	value = [],
	...props
}) {
	React.useEffect(() => {
		onFocus()
		return onBlur
	}, [onFocus, onBlur])

	return (
		<InkMultiSelect
			{...props}
      selected={value.map(value => ({label: value, value}))}
			onSelect={({ value: v }) => onChange(value.concat(v))}
			onUnselect={({ value: v }) => onChange(value.filter(item => item !== v))}
		/>
	)
}
