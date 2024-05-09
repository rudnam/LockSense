import { CssBaseline } from "@mui/material";
import Box from "@mui/material/Box";
import React from "react";
import PrimaryText from "src/components/PrimaryText";

const Home: React.FC = () => {
  return (
    <Box>
      <CssBaseline />
      <h1>
        Welcome to <PrimaryText>LockSense</PrimaryText>.
      </h1>
      <p>
        <PrimaryText>LockSense</PrimaryText> is a smart lock that you can manage
        on the cloud.
      </p>
      <p>
        Forgot your keys? No problem! You can use the{" "}
        <PrimaryText>LockSense app</PrimaryText> to unlock your doors.
      </p>
      <p>
        Use it to let family or friends into your home without even needing to
        be there before them!
      </p>
    </Box>
  );
};

export default Home;
