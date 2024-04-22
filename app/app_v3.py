import logging

def main():
    # Initialize logging
    logging.basicConfig(filename="access.log", level=logging.INFO)
    logging.info("User accessed the site")

    # Add an infinite loop to keep the application running
    while True:
        pass

if __name__ == "__main__":
    main()
