import os

def main():
    print(f"CPU Usage: {os.getloadavg()[0]}")

    # Add an infinite loop to keep the application running
    while True:
        pass

if __name__ == "__main__":
    main()
