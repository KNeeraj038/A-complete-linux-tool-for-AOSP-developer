# AndroidLoggingTool-Linux

To make your script accessible from anywhere in Linux, you can add it to a directory listed in the `PATH` environment variable. Here's how you can do it:

1. Choose a directory to store your custom scripts. For example, you can create a `bin` directory in your home folder. Open a terminal and run the following command to create the directory:
```bash
mkdir ~/bin
```

2. Move your script to the `bin` directory. Assuming your script is named `start_log.sh` and `android_log.sh`, and they are located in the current directory, run the following command:
```bash
mv start_log.sh android_log.sh ~/bin/
```

3. Add the `bin` directory to your `PATH` environment variable. Open the `.bashrc` file in a text editor using the following command:
```bash
nano ~/.bashrc
```

4. Add the following line at the end of the file:
```bash
export PATH="$HOME/bin:$PATH"
```

5. Save the changes and exit the text editor (in Nano, press `Ctrl+X`, then `Y`, then `Enter`).

6. To apply the changes immediately, run the following command in the terminal:
```bash
source ~/.bashrc
```

Now, you should be able to run your script from anywhere by simply typing its name, like any other command. In this case, you can use the following command to execute your script:
```bash
start_log.sh
```

Make sure the script has the execute permission set. If not, you can set it using the following command:
```bash
chmod +x ~/bin/start_log.sh
```
