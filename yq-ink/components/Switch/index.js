import React, { createContext, useContext } from "react";

const Context = createContext();

export default function Switch({ value, children }) {
  return <Context.Provider value={value}>{children}</Context.Provider>;
}

function MultiCase({ value, children }) {
  const contextValue = useContext(Context);
  if (Array.isArray(value) && value.includes(contextValue)) {
    return children || null;
  }

  return null;
}

function Case({ value, children }) {
  const contextValue = useContext(Context);

  if (contextValue !== value) {
    return null;
  }

  return children || null;
}

Switch.Case = Case;
Switch.MultiCase = MultiCase;
