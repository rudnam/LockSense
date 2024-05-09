import React, { useEffect, useState } from "react";
import firebaseService from "../services/firebase";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemText from "@mui/material/ListItemText";
import ListItemAvatar from "@mui/material/ListItemAvatar";
import Avatar from "@mui/material/Avatar";
import CableIcon from "@mui/icons-material/Cable";
import LightbulbIcon from "@mui/icons-material/Lightbulb";
import Switch from "@mui/material/Switch";
import { BinaryState } from "src/types";
import { amber } from "@mui/material/colors";

interface StateItem {
  name: string;
  icon: any;
  dbPath: string;
  state: any;
  setState: React.Dispatch<React.SetStateAction<any | null>>;
}

const StateList: React.FC = () => {
  let [ledState, setLedState] = useState<BinaryState | null>(null);
  let [photoresistorState, setPhotoresistorState] =
    useState<BinaryState | null>(null);

  const states: StateItem[] = [
    {
      name: "Led",
      icon: <LightbulbIcon />,
      dbPath: "led/state",
      state: ledState,
      setState: setLedState,
    },
    {
      name: "Photoresistor",
      icon: <CableIcon />,
      dbPath: "photoresistor/state",
      state: photoresistorState,
      setState: setPhotoresistorState,
    },
  ];

  useEffect(() => {
    const fetchData = async () => {
      try {
        firebaseService.addListener("led/state", (data) => {
          setLedState(data);
        });
        firebaseService.addListener("photoresistor/state", (data) => {
          setPhotoresistorState(data);
        });
      } catch (error) {
        console.error(error);
      }
    };

    fetchData();
  }, []);

  const handleSwitchClick = (state: StateItem) => {
    const newState = state.state === 0 ? 1 : 0;
    try {
      firebaseService.writeData(state.dbPath, newState);
    } catch (err) {
      console.error(err);
    } finally {
      state.setState(newState);
    }
  };

  return (
    <List sx={{ width: "100%", maxWidth: 360, bgcolor: "background.paper" }}>
      {states.map((state) => {
        return (
          <ListItem>
            <ListItemAvatar>
              <Avatar sx={state.state === 1 ? { bgcolor: amber[500] } : {}}>
                {state.icon}
              </Avatar>
            </ListItemAvatar>
            <ListItemText
              primary={`${state.name} State: ${
                state.state === null ? "..." : state.state === 1 ? "On" : "Off"
              }`}
            />
            <Switch
              checked={state.state === 1}
              onClick={() => handleSwitchClick(state)}
            />
          </ListItem>
        );
      })}
    </List>
  );
};

export default StateList;
