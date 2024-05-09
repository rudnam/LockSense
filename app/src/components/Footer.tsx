import { useTheme } from "@mui/material";
import Box from "@mui/material/Box";
import React from "react";
import GitHubIcon from "@mui/icons-material/GitHub";
import { Link } from "react-router-dom";

const Footer: React.FC = () => {
  const theme = useTheme();

  return (
    <Box className="flex flex-row gap-6 mt-auto py-4 items-center justify-center text-gray-500 text-xs md:text-sm">
      <span>© 2024 CS 145 Group 0xD</span>
      <Link
        to="https://github.com/rudnam/LockSense"
        target="_blank"
        rel="noopener noreferrer"
      >
        <GitHubIcon
          className="hover:text-green"
          sx={{
            mr: 1,
            "&:hover": {
              color: theme.palette.primary.main,
              cursor: "pointer",
            },
          }}
        />
      </Link>
    </Box>
  );
};

export default Footer;
