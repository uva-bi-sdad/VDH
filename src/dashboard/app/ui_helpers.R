make_id <- function(l) {
  paste0("select_", gsub("\\s", "", l))
}

input_select <- function(label, options, ..., variable = NULL, default = NULL,
                         display = options, id = make_id(label), reset_button = FALSE) {
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
          HTML(paste0(
            "<input type='radio' value='", options[i], "'",
            if (options[i] == default) " checked",
            ">", display[i], "</input>"
          ))
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
          HTML(paste0(
            "<input type='radio' value='", options[i], "'",
            " id='", oid, "' name='", paste0(id, "_options"), "'",
            if (options[i] == default) " checked",
            "></input>"
          ))
        )
      })
    )
  )
}
