import React from "react";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import TopBar from "./components/TopBar";
import { Route, Routes } from "react-router-dom";
import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";
import Account from "./pages/Account";
import useMediaQuery from "@mui/material/useMediaQuery";
import CssBaseline from "@mui/material/CssBaseline";
import { green } from "@mui/material/colors";
import Footer from "./components/Footer";
import Box from "@mui/material/Box";
import Divider from "@mui/material/Divider";

function App() {
  const prefersDarkMode = useMediaQuery("(prefers-color-scheme: dark)");
  const theme = React.useMemo(
    () =>
      createTheme({
        palette: {
          mode: prefersDarkMode ? "dark" : "light",
          primary: {
            main: green[500],
          },
        },
      }),
    [prefersDarkMode]
  );

  return (
    <>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Box className="h-screen flex flex-col items-center">
          <TopBar />
          <main className="grow w-5xl mx-auto p-4 flex flex-col items-center text-center">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/account" element={<Account />} />
            </Routes>
          </main>
          <Divider variant="middle" flexItem />
          <Footer />
        </Box>
      </ThemeProvider>
    </>
  );
}

export default App;
