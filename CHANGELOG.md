# Changelog

The noteworthy changes for each ActionView::Attributes version are included
here. For a complete changelog, see the [commits][] for each version via the
version links.

[commits]: https://github.com/seanpdoyle/action_view-attributes

## main

## 0.1.3 (Sep 27, 2024)

*   Expand version matrix to support `ruby@3.3` and `rails@7.2`

    *Sean Doyle*

## 0.1.2 (Feb 8, 2023)

*   Special case `data-action` descriptor syntax like `->` when escaping
    `token_list` calls

    *Sean Doyle*

## 0.1.1 (Feb 8, 2023)

*   Ensure that attribute values like [data-action](https://stimulus.hotwired.dev/reference/actions)
    descriptor syntax aren't escaped too many times when transformed to Token Lists

    *Sean Doyle*

## 0.1.0 (Feb 5, 2023)

*   Extract out of [attributes_and_token_lists](https://github.com/seanpdoyle/attributes_and_token_lists)
