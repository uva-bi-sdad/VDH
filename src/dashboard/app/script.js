'use strict'
var current_options = {},
  locationsByName = {},
  measureByDisplay = {},
  default_bounds = {},
  trace_template = '',
  plots = [],
  map,
  _u = {},
  _s = {},
  _c = {}

function pal(value) {
  const colors = [
      '#FFD67E',
      '#F0C471',
      '#E1B265',
      '#D3A158',
      '#C48F4C',
      '#B57D3F',
      '#A76C33',
      '#985A26',
      '#89481A',
      '#7B370E',
    ],
    range = measures[_s.select_variable].summaries[_s.select_shapes]
  return typeof value === 'number'
    ? colors[
        Math.max(
          0,
          Math.min(
            colors.length - 1,
            Math.ceil(
              ((colors.length - 1) * (value + range.min[_u.select_year.current_index])) /
                (range.min[_u.select_year.current_index] + range.max[_u.select_year.current_index])
            )
          )
        )
      ]
    : '#808080'
}

function make_data_entry(group, id, variable, name, color) {
  const d = features[group][id]
  for (var i = d[variable].length, e = JSON.parse(trace_template); i--; ) {
    e.text[i] = name
    e.x[i] = d.year[i]
    e.y[i] = d[variable][i]
  }
  e.color =
    e.line.color =
    e.marker.color =
    e.marker.line.color =
    e.textfont.color =
      color || pal(d[variable][_u.select_year.current_index])
  e.name = name
  return e
}

const varnames = Object.keys(measures),
  update_map = {
    scale: 'select_scale',
    county: 'select_region',
    district: 'select_region',
    year: 'select_year',
  },
  updaters = {
    polygons: function () {
      const all = _s[_s.select_scale] === 'All'
      var k, layer
      if (_s.select_scale === 'county' && _s.select_shapes === 'district') {
        _u.select_shapes.set('county')
      }
      if (all) {
        map.flyToBounds(default_bounds)
      } else {
        map.flyToBounds(
          map.layerManager._byLayerId['shape\n' + locationsByName[_s.select_scale][_s[_s.select_scale]].id].getBounds()
        )
      }
      for (k in map.layerManager._byLayerId)
        if (Object.prototype.hasOwnProperty.call(map.layerManager._byLayerId, k)) {
          layer = map.layerManager._byLayerId[k]
          if (layer.options.group === _s.select_shapes) {
            if (
              all ||
              _s[_s.select_scale] ===
                locations[layer.options.group][layer.options.layerId][
                  _s.select_scale === 'county' ? 'county_name' : 'health_district'
                ]
            ) {
              layer.setStyle({
                fillColor: pal(
                  features[layer.options.group][layer.options.layerId][_s.select_variable][_u.select_year.current_index]
                ),
                weight: 1,
                fillOpacity: 0.7,
              })
              layer.addTo(map)
              continue
            }
          }
          layer.remove()
        }
    },
    map_legend: function () {
      map.controls._controlsById.legend._container.firstElementChild.innerHTML =
        '<strong>' + measures[_s.select_variable].name + ' Score</strong>'
    },
    plot_main: function () {
      const data = features[_s.select_shapes],
        s = measures[_s.select_variable].summaries[_s.select_shapes],
        sel = _s.select_scale === 'county' ? 'county_name' : 'health_district'
      var id,
        i,
        traces = [],
        sorted = []
      function top_to_series(i, n) {
        for (; i < n; i++) {
          traces.splice(
            0,
            0,
            make_data_entry(
              _s.select_shapes,
              sorted[i].id,
              _s.select_variable,
              locations[_s.select_shapes][sorted[i].id].name
            )
          )
        }
      }
      for (id in data)
        if (Object.prototype.hasOwnProperty.call(data, id)) {
          if (
            typeof data[id][_s.select_variable][_u.select_year.current_index] === 'number' &&
            (_s[_s.select_scale] === 'All' || locations[_s.select_shapes][id][sel] === _s[_s.select_scale])
          ) {
            i = sorted.length
            if (
              !i ||
              data[id][_s.select_variable][_u.select_year.current_index] >
                sorted[i - 1].data[_u.select_year.current_index]
            ) {
              sorted.push({id: id, data: data[id][_s.select_variable]})
            } else {
              for (; i--; ) {
                if (
                  data[id][_s.select_variable][_u.select_year.current_index] >
                  sorted[i].data[_u.select_year.current_index]
                ) {
                  sorted.splice(i + 1, 0, {id: id, data: data[id][_s.select_variable]})
                  break
                }
              }
              if (i === -1) {
                sorted.splice(0, 0, {id: id, data: data[id][_s.select_variable]})
              }
            }
          }
        }
      top_to_series(0, Math.min(5, sorted.length))
      if (sorted.length > 5) top_to_series(Math.max(5, sorted.length - 5), sorted.length)
      for (i = plots[0].data.length; i--; ) {
        if (plots[0].data[i].type === 'box') {
          plots[0].data[i].x = data[id].year
          delete plots[0].data[i].y
          plots[0].data[i].upperfence = s.max
          plots[0].data[i].q3 = s.q3
          plots[0].data[i].median = s.median
          plots[0].data[i].q1 = s.q1
          plots[0].data[i].lowerfence = s.min
          traces.push(plots[0].data[i])
        }
      }
      Plotly.react(plots[0], traces, plots[0].layout)
    },
  },
  getters = {
    buttongroup: function () {
      $.each(
        this.options,
        function (i, e) {
          if (e.checked) {
            this.update(e.value, i, true)
            return false
          }
        }.bind(this)
      )
      return this.current
    },
    radio: function () {
      $.each(
        this.options,
        function (i, e) {
          if (e.checked) {
            this.update(e.value, i, true)
            return false
          }
        }.bind(this)
      )
      return this.current
    },
    select: function () {
      this.update(this.e.value, this.e.selectedIndex, true)
      return this.current
    },
  },
  setters = {
    buttongroup: function (v) {
      if (this.current !== v && this.values.indexOf(v) !== -1) {
        $.each(this.options, function (i, e) {
          if (e.value === v) {
            e.checked = true
            e.parentElement.classList.add('active')
            this.update(v, i)
          } else {
            e.parentElement.classList.remove('active')
          }
        })
      }
    },
    radio: function (v) {
      if (this.current !== v && this.values.indexOf(v) !== -1) {
        $.each(this.options, function (i, e) {
          if (e.value === v) {
            e.checked = true
            this.update(v, i)
          }
        })
      }
    },
    select: function (v) {
      if (this.current !== v) {
        const i = this.values.indexOf(v)
        if (i !== -1) {
          this.e.selectedIndex = i
          this.update(v, i)
        }
      }
    },
    update_select: function (v, i, passive) {
      this.previous = this.current
      this.current = _s[this.id] = v
      this.current_index = i
      if (Object.prototype.hasOwnProperty.call(_c, this.id)) {
        for (var i = _c[this.id].length; i--; ) {
          if (Object.prototype.hasOwnProperty.call(_u, _c[this.id][i])) {
            _u[_c[this.id][i]].e.parentElement.parentElement.classList[
              this.current === _c[this.id][i] ? 'remove' : 'add'
            ]('hidden')
          }
        }
      }
      if (!passive) update()
    },
  },
  listeners = {
    buttongroup: function (e) {
      this.update(e.target.value, this.display.indexOf(e.target.value))
    },
    radio: function (e) {
      this.update(e.target.value, this.display.indexOf(e.target.value))
    },
    select: function (e) {
      this.update(e.target.value, e.target.selectedIndex)
    },
  }

function update() {
  updaters.polygons()
  updaters.plot_main()
}

window.onload = function () {
  // make inverted location object
  var g, k
  for (g in locations)
    if (Object.prototype.hasOwnProperty.call(locations, g)) {
      locationsByName[g] = {All: {id: ''}}
      for (k in locations[g])
        if (Object.prototype.hasOwnProperty.call(locations[g], k)) {
          locationsByName[g][locations[g][k].name] = locations[g][k]
        }
    }

  // make variable and level name map
  for (k in measures)
    if (Object.prototype.hasOwnProperty.call(measures, k)) {
      measureByDisplay[measures[k].name] = k
    }

  // identify page components
  map = $('.leaflet')[0].htmlwidget_data_init_result.getMap()
  default_bounds = map.getBounds()

  // retrieve plot elements
  $('.plotly').each(function (i, e) {
    plots.push(e)
  })
  trace_template = JSON.stringify(plots[0].data[0])

  // add interaction functions to region shapes
  function add_layer_listeners(name, layer) {
    layer.on({
      mouseover: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId')) {
          e.target.setStyle({
            weight: 2,
            fillOpacity: 1,
          })
          var trace = make_data_entry(
            e.target.options.group,
            e.target.options.layerId,
            _s.select_variable,
            'hover_line',
            '#000'
          )
          trace.line.width = 4
          Plotly.addTraces(plots[0], trace, plots[0].data.length)
        }
      },
      mouseout: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId')) {
          e.target.setStyle({
            weight: 1,
            fillOpacity: 0.7,
          })
          if (plots[0].data[plots[0].data.length - 1].name === 'hover_line')
            Plotly.deleteTraces(plots[0], plots[0].data.length - 1)
        }
      },
      click: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId') && e.target.options.group !== 'tract') {
          _s.selected_layer = e.target.options.layerId
          _u[e.target.options.group].set(locations[e.target.options.group][e.target.options.layerId].name)
        }
      },
    })
  }
  $.each(map.layerManager._byLayerId, add_layer_listeners)

  // connect inputs
  $('.auto-input').each(function (i, e) {
    var o = {
        type: e.getAttribute('auto-type'),
        id: e.id,
        current: '',
        current_index: -1,
        previous: '',
        e: e,
        values: [],
        display: [],
      },
      c
    o.options = o.type === 'select' ? e.children : e.getElementsByTagName('input')
    o.update = setters.update_select.bind(o)
    o.set = setters[o.type].bind(o)
    o.get = getters[o.type].bind(o)
    o.reset = function (e) {
      if (this.default !== this.current) this.set(this.default)
    }.bind(o)
    o.listen = listeners[o.type].bind(o)
    _u[e.id] = o

    // retrieve option values
    $(e.children).each(function (i, e) {
      o.values[i] = o.options[i].value
      o.display[i] = e.innerText.trim() || o.values[i]
    })

    // add listeners
    if (o.type === 'select') {
      $(e).on('change', o.listen)
      if (e.nextElementSibling && e.nextElementSibling.className === 'input-group-append') {
        $(e.nextElementSibling.firstElementChild).on('click', o.reset)
      }
    } else {
      $(o.options).on('click', o.listen)
    }

    // update display condition
    if ((c = e.getAttribute('condition'))) {
      if (!Object.prototype.hasOwnProperty.call(_c, c)) _c[c] = []
      _c[c].push(e.id)
      if (Object.prototype.hasOwnProperty.call(_s, c) && _s[c] === e.id) {
        e.parentElement.parentElement.classList.remove('hidden')
      }
    }

    // get initial values
    _s[e.id] = o.default = o.get()
  })
  setTimeout(update, 0)
}
