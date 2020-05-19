# trello-todo
This is a simple wrapper around [trello-cli](https://github.com/mheap/trello-cli) that makes it easier to manage [Trello](https://trello.com)

## Installation
1. Check out a clone of this repo to a location of your choice, such as `git clone https://github.com/artbit/trello-todo ~/.trello-todo`
2. Source it `source ~/.trello-todo/trello-todo.sh` (you can add this line to your `.bashrc` to automatically add it for every session)
3. Install dependencies: `npm i -g trello-cli`
 -  Run `trello` to generate basic config in your home directory.
 -  [Get an API key](https://trello.com/app-key) and put it in `~/.trello-cli/config.json`
4. Run `todo refresh` to refresh the list of Trello boards and lists.

## Usage
```bash
todo --help
```

## Examples
```bash
# Add a new board called "Daily Tasks"
todo add "Daily Tasks"

# Add a few lists to the newly cerated board
todo add "Daily Tasks/ToDo"
todo add "Daily Tasks/Doing"
todo add "Daily Tasks/Done"

# Add a few cards to the ToDo list
todo add "daily/todo/Readme" "Write a README.md"
todo add "daily/todo/Push Changes" "Push changes to GitHub"

# Move the cards around
todo move "daily/todo/readme" "daily/doing"
todo move "daily/doing/readme" "daily/done"

todo move "daily/todo/push" "daily/doing"
todo move "daily/doing/push" "daily/done"

# Show the ToDo list
todo web "daily/todo"

# Or open the "Daily Tasks" board in the browser
todo web "daily"
```

## License
MIT
