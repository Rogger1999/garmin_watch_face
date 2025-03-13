# Elegant Analog Garmin Watch Face

A sophisticated analog watch face for Garmin devices, featuring elegant hands, special hour markers, and important fitness metrics.

## Features

- **Elegant Analog Design**: Polished watch hands with smooth rendering
- **Special Hour Markers**: Distinctive red circular markers at 3, 6, and 9 o'clock positions
- **Fitness Statistics**: Display of important metrics including:
  - Heart rate monitor
  - Battery percentage
  - Step count
- **Refined Details**:
  - Smooth tapered watch hands with highlight edges
  - Distinctive hour and minute hands with customized lengths and thicknesses
  - Elegant red second hand with counterbalance
  - Sophisticated center dot with concentric circles

## Compatible Devices

- Fenix 7X Pro (No WiFi)
- (Add other compatible Garmin devices here)

## Installation

1. Download the latest `.prg` file from the Releases section
2. Connect your Garmin device to your computer
3. Copy the `.prg` file to the `/GARMIN/APPS/` directory on your device
4. Disconnect your device
5. On your Garmin device, navigate to Settings > Watch Face and select "Elegant Analog"

## Development

This watch face is built using the Connect IQ SDK and Monkey C programming language.

### Prerequisites

- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- Visual Studio Code with Monkey C extension

### Building from Source

1. Clone this repository
2. Open in VS Code with the Monkey C extension installed
3. Build using the Monkey C: Build command
4. Use the Monkey C: Run command to test in the simulator

## Customization

The watch face can be customized by modifying the following constants in the `WatchHandsView.mc` file:

- `SPECIAL_MARKER_SIZE`: Adjust the size of the special hour markers
- `COLOR_LIGHT_ORANGE`, `COLOR_RED`, etc.: Change the colors of various elements

Hand dimensions can be modified in the `drawSmoothHourHand` and `drawSmoothMinuteHand` functions.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

