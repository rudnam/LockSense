import Box from "@mui/material/Box";
import React from "react";
import StateList from "src/components/StateList";

const Dashboard: React.FC = () => {
  return (
    <Box>
      <h1>Dashboard</h1>
      <StateList />
    </Box>
  );
};

export default Dashboard;
