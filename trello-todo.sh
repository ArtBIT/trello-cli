#!/usr/bin/env bash

_usage() {
    command="todo"
    padding="    "
    cat <<USAGE
${command} is a CLI helper for Trello board (https://trello.com)
Usage:
    ${command} [h|help|-h|--help]       Shows this screen.

    ${command} [r|refresh]              Reloads data from the trello cloud.

    ${command} [a|add] CARDPATH/title [description]
    ${padding}                          Adds a new card titled 'title' with
    ${padding}                          optional description.

    ${command} [d|delete] CARDPATH      Delete a card, list or a board.
        Examples:
           \$> ${command} d "Daily Tasks"   
    ${padding}                          Deletes the board "Daily Tasks".

           \$> ${command} d "Daily Tasks/Todo"
    ${padding}                          Deletes the list "Todo" in the
    ${padding}                          board "Daily Tasks".

           \$> ${command} d "Daily Tasks/Todo/Call"
    ${padding}                          Deletes the card titled "Call" on
    ${padding}                          the list "Todo" in the 
    ${padding}                          board "Daily Tasks".

    ${command} [v|view] [CARDPATH]      Shows the contents of a card, 
    ${padding}                          list, or a board defined by the
    ${padding}                          CARDPATH.

    ${command} [m|move] CARDPATH CARDPATH
    ${padding}                          Move a card defined by the first 
    ${padding}                          CARDPATH to another CARDPATH.
        Examples:
           \$> ${command} m "Daily Tasks/Todo/Call"  "Daily Tasks/Done"
    ${padding}                          Moves the card titled "Call"
    ${padding}                          from the list "Todo" of the
    ${padding}                          board "Daily Tasks" to the
    ${padding}                          list called "Done" on the 
    ${padding}                          same board.

           \$> ${command} m "daily/todo/call"  "daily/done"
    ${padding}                          Similarly, you can use parts of
    ${padding}                          the board/list/card names using
    ${padding}                          case-insensitive strings to
    ${padding}                          type the same action more
    ${padding}                          quickly.
    ${padding}                          NOTE: In case of multiple matches
    ${padding}                          the first match will be used.

    ${command} [w|web] CARDPATH         Opens the board/list/card in the
    ${padding}                          Trello web app in a browser.

    CARDPATH                      CARDPATH is simply a forward-slash
                                  delimited string that describes
                                  the board/list/card as a simple 
                                  folder structure.
                                  It is not case sensitive, and
                                  you do not need to provide the
                                  full board/list/card names, but
                                  can use substrings instead.
                                  The following are all identical:
                                   "Daily Tasks/Todo/Call"
                                   "daily/todo/call"
                                   "tasks/tod/call"
                                   Bear in mind that in case you
                                   have multiple boards/lists/cards
                                   that share the same substring, 
                                   the first match will be used.
                                   You have to provide a substring
                                   that is unique to the specific
                                   board/list/card.

                                    
USAGE
}

_open_in_browser() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        nohup xdg-open "$@" > /dev/null 2>&1
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        open -a "Google Chrome" "$@" /dev/null 2>&1
    fi
}

_check_for_trello() {
    command -v trello > /dev/null 2>&1
    if [ "$?" -eq 0 ]; then
        return 0
    fi
    cat <<USAGE
This command is a wrapper around the npm package trello. 
You have to install it first by running 
    npm install -g trello-cli
Fell free to read more about it on https://github.com/mheap/trello-cli
USAGE
    return 1
}

_get_boardid() {
    trello show-boards | grep -i "$1" | head -1 | sed -e 's/.* (ID: //' -e 's/).*//'
}

_get_board() {
    trello show-boards | grep -i "$1" | head -1 | sed 's/ (ID: .*//'
}

_get_listid() {
    trello show-lists -b "$1" | grep -i "$2" | head -1 | sed -e 's/.* (ID: //' -e 's/).*//'
}

_get_list() {
    trello show-lists -b "$1" | grep -i "$2" | head -1 | sed 's/ (ID: .*//'
}

_get_cardid() {
    trello show-cards -b "$1" -l "$2" | grep -i "$3" | head -1 | sed 's/^.*\* \([^ ]*\) -.*/\1/'
}

_get_card() {
    trello show-cards -b "$1" -l "$2" | grep -i "$3" | head -1 | sed 's/^.*- //'
}

_parse_breadcrumbs() {
  local board
  local list
  local card
  IFS=':>/' read -r board list card <<< "$1"
  if [ ! -z "$board" ]; then
      board=$(_get_board "$board")
  fi
  if [ ! -z "$list" ]; then
      list=$(_get_list "$board" "$list")
  fi
  if [ ! -z "$card" ]; then
      card=$(_get_cardid "$board" "$list" "$card")
  fi
  echo "$board:$list:$card"
}

_create() {
  local board
  local list
  local card
  local cid
  IFS=':>/' read -r board list card <<< "$1"
  IFS=':' read -r bid lid cid < <(_parse_breadcrumbs "$1")
  description="$2"
  shift 2


  if [ ! -z "$card" ]; then
    trello add-card "$card" "$description" -b "$bid" -l "$lid" "$@"
    _view "$board:$list"
    return;
  fi
  if [ ! -z "$list" ]; then
    trello add-list -b "$bid" -l "$list" "$@"
    _view "$board"
    return;
  fi
  if [ ! -z "$board" ]; then
    trello add-board -b "$board" -p "private" "$@"
    _view
  fi
}

_move() {
  local board
  local list
  local cardid
  IFS=':' read -r board list cardid < <(_parse_breadcrumbs "$1")
  IFS=':' read -r board list < <(_parse_breadcrumbs "$2")
  shift 2
  local listid=$(_get_listid "$board" "$list")
  if [ ! -z "$cardid" ]; then
    trello move-card "$cardid" "$listid"
    _view "$board:$list"
    return;
  fi
}

_delete() {
  local board
  local list
  local card
  local cid
  IFS=':>/' read -r board list card <<< "$1"
  IFS=':' read -r board list cid < <(_parse_breadcrumbs "$1")
  shift 1
  if [ ! -z "$card" ]; then
    trello delete-card "$card" -b "$board" -l "$list"
    _view "$board:$list"
    return;
  fi
  if [ ! -z "$list" ]; then
    _view "$board"
    return;
  fi
  if [ ! -z "$board" ]; then
    trello close-board -b "$board" "$@"
    _view 
  fi
}

_view() {
  local board
  local list
  local cardid
  IFS=':' read -r board list cardid < <(_parse_breadcrumbs "$1")
  shift 1

  if [ ! -z "$cardid" ]; then
    trello card-details "$cardid"
    return;
  fi
  if [ ! -z "$list" ]; then
    trello show-cards -b "$board" -l "$list" "$@"
    return;
  fi
  if [ ! -z "$board" ]; then
    trello show-lists -b "$board" "$@"
    return
  fi
  trello show-boards "$board" "$list" "$@"
}

_web() {
  local board
  local list
  local cardid
  IFS=':' read -r board list cardid < <(_parse_breadcrumbs "$1")
  shift 1
  if [ ! -z "$cardid" ]; then
    _open_in_browser https://trello.com/c/$cardid
    return;
  fi
  if [ ! -z "$list" ]; then
    local listid=$(_get_listid "$board" "$list")
    _open_in_browser https://trello.com/l/$listid
    return;
  fi
  if [ ! -z "$board" ]; then
    local boardid=$(_get_boardid "$board")
    _open_in_browser https://trello.com/b/$boardid
    return
  fi

  _open_in_browser https://trello.com/
}

todo() {
  args=( "$@" )
  local command="$1"
  shift
  _check_for_trello
  if [ "$?" -eq 1 ]; then
      return
  fi

  case "$command" in
    r|refresh)
      trello refresh
      ;;
    a|add)
      _create "$@"
      ;;
    d|delete)
      _delete "$@"
      ;;
    v|view)
      _view "$@"
      ;;
    m|move)
      _move "$@"
      ;;
    w|web)
      _web "$@"
      ;;
    h|help|-h|--help)
      _usage
      ;;
    *)
      _view "${args[@]}"
      ;;
  esac
}
