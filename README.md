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
This is a CLI helper for Trello board (https://trello.com)
USAGE:
    todo COMMAND CARDPATH [OPTIONS]

ARGS:
    <CARDPATH> = <BOARD>[/<LIST>[/CARD]]
            is simply a forward-slash delimited string that describes
            the BOARD/LIST/CARD as a simple folder structure.  It is
            not case sensitive, and you do not need to provide the full
            BOARD/LIST/CARD names, but can use substrings instead.
            The following are all identical: "Daily Tasks/Todo/Call"
            "daily/todo/call" "tasks/tod/call" Bear in mind that in
            case you have multiple boards/lists/cards that share the
            same substring, the first match will be used.  You have
            to provide a substring that is unique to the specific
            BOARD/LIST/CARD.

COMMANDS:
    h, help
            Shows this screen.

    r, refresh
            Reloads data from the Trello cloud.

    a, add CARDPATH/TITLE [DESCRIPTION]
            Adds a new card titled TITLE with optional DESCRIPTION to
            the BOARD/LIST specified in the CARDPATH.

    d, delete CARDPATH
            Delete a card, list or a board.
            Examples:
               $ todo d "Daily Tasks"   
                Deletes the board "Daily Tasks".

               $ todo d "Daily Tasks/Todo"
                Deletes the list "Todo" in the board "Daily Tasks".

               $ todo d "Daily Tasks/Todo/Call"
                Deletes the card titled "Call" on the list "Todo" in the
                board "Daily Tasks".

    v, view [CARDPATH]
            Shows the contents of a card, list, or a board defined by
            the CARDPATH.

    m, move CARDPATH CARDPATH
            Move a card defined by the first CARDPATH to another
            CARDPATH.
            Examples:
                $ todo m "Daily Tasks/Todo/Call"  "Daily Tasks/Done"
                Moves the card titled "Call" from the list "Todo" of the
                board "Daily Tasks" to the list called "Done" on the
                same board.

                $ todo m "daily/todo/call"  "daily/done"
                Similarly, you can use parts of the board/list/card
                names using case-insensitive strings to type the same
                action more quickly.
                NOTE: In case of multiple matches the first match will
                be used.

    w, web CARDPATH
            Opens the board/list/card in the Trello web app in a browser.

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
