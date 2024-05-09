import React, { ReactNode } from "react";
import useTheme from "@mui/material/styles/useTheme";

interface Props {
  children?: ReactNode;
}

const PrimaryText: React.FC<Props> = ({ children }) => {
  const theme = useTheme();
  return (
    <span
      style={{
        color: theme.palette.primary.main,
      }}
    >
      {children}
    </span>
  );
};

export default PrimaryText;
