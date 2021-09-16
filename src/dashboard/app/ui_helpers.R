make_id <- function(l) {
  paste0("select_", gsub("\\s", "", l))
}

output_info <- function(title = "Overall", message = "") {
  div(
    id = "summary",
    class = "auto-output text-display",
    "auto-type" = "info",
    lapply(c("", "hidden"), function(cl) {
      div(
        class = cl,
        h1(title),
        p(if (cl == "") message else ""),
        tags$table(class = "table location-table"),
        h2("Variable"),
        tags$table(class = "table measure-table"),
      )
    })
  )
}

input_select <- function(label, options, ..., variable = NULL, default = NULL,
                         display = options, id = make_id(label), multi = FALSE, reset_button = FALSE) {
  if (missing(default)) default <- options[1]
  list(
    tags$label(label, `for` = id),
    div(
      class = if (reset_button) "input-group mb-3" else "",
      tags$select(
        id = id,
        class = "auto-input custom-select",
        "auto-type" = "select",
        variable = variable,
        multi = if (multi) NA else NULL,
        ...,
        lapply(seq_along(options), function(i) tags$option(value = options[i], display[i]))
      ),
      if (!missing(reset_button)) {
        div(class = "input-group-append", tags$button(
          class = "btn btn-outline-default",
          type = "button",
          if (is.character(reset_button)) reset_button else "Reset"
        ))
      }
    )
  )
}

input_buttongroup <- function(label, options, ..., variable = NULL, default = NULL,
                              display = options, id = make_id(label)) {
  if (missing(default)) default <- options[1]
  list(
    tags$label(label, `for` = id),
    div(
      id = id,
      class = "auto-input btn-group btn-group-toggle",
      style = "width: 100%",
      "data-toggle" = "buttons",
      "auto-type" = "buttongroup",
      variable = variable,
      ...,
      lapply(seq_along(options), function(i) {
        tags$label(
          class = paste0("btn btn-default", if (options[i] == default) " active"),
          tags$input(
            type = "radio",
            value = options[i],
            checked = if (options[i] == default) NA else NULL,
            display[i]
          )
        )
      })
    )
  )
}

input_radio <- function(label, options, ..., variable = NULL, default = NULL,
                        display = options, id = make_id(label)) {
  if (missing(default)) default <- options[1]
  div(
    tags$label(`for` = id, label),
    div(
      id = id,
      class = "auto-input",
      "auto-type" = "radio",
      variable = variable,
      lapply(seq_along(options), function(i) {
        oid <- paste0(id, "_", options[i])
        div(
          id = id,
          class = "form-check",
          tags$label(class = "form-check-label", `for` = oid, display[i]),
          tags$input(
            id = oid,
            name = paste0(id, "_options"),
            type = "radio",
            value = options[i],
            checked = if (options[i] == default) NA else NULL
          )
        )
      })
    )
  )
}
