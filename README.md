# CPU Performance Script for EPYC/Ryzen CPUs

This repository contains scripts to optimize and monitor CPU performance for servers running AMD EPYC or Ryzen processors.

## Overview

The `set_cpu_performance.sh` script is designed to:

- Set all CPU cores to performance mode
- Enable CPU boost if available
- Provide a detailed summary of CPU specifications and performance metrics

⚠️ **Note**: This script is specifically designed for AMD EPYC and Ryzen CPUs. It may not work correctly or may be unnecessary for other CPU architectures.

## Quick Setup

To set up the script on your server, run the following command:

```bash
curl -s https://raw.githubusercontent.com/mjessup/scripts/main/setup.sh | bash
```

This command will:
1. Download and install the latest version of the script
2. Set up cron jobs to run the script at reboot and every 6 hours
3. Provide immediate feedback on the setup process

## Features

- Automatic CPU governor setting to performance mode
- CPU boost enabling (if available)
- Detailed CPU information display, including:
  - System overview
  - CPU specifications
  - Cache information
  - Advanced CPU details
  - Current performance status

## Requirements

- AMD EPYC or Ryzen CPU
- Root access to the server
- `curl` installed on the system

## Logs

The script logs its activities to `/root/scripts/logs/cpu_performance.log`.

## Caution

This script modifies system settings. While it's designed to optimize performance, please ensure you understand the implications for your specific use case before running it on production systems.

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements or encounter any problems.

## License

[MIT License](LICENSE)
