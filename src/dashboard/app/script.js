'use strict'
var data = {},
  locationsByName = {},
  measureByDisplay = {},
  default_bounds = {},
  trace_template = '',
  sorted_layers = [],
  selected_layers = {},
  page = {
    map: null,
    plots: [],
  },
  _u = {},
  _s = {},
  _c = {}

function pal(value, grey) {
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
    greys = [
      '#EDEDED90',
      '#D2D2D290',
      '#B8B8B890',
      '#9E9E9E90',
      '#83838390',
      '#69696990',
      '#4F4F4F90',
      '#34343490',
      '#1A1A1A90',
      '#00000090',
    ],
    range = measures[_s.variable].summaries[_s.shapes]
  return typeof value === 'number'
    ? (grey ? greys : colors)[
        Math.max(
          0,
          Math.min(
            colors.length - 1,
            Math.round(
              (colors.length * (value + range.min[_u.year.current_index])) /
                (range.min[_u.year.current_index] + range.max[_u.year.current_index])
            )
          )
        )
      ]
    : '#808090'
}

function make_data_entry(group, id, variable, name, color) {
  const d = data[group][id]
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
      color || pal(d[variable][_u.year.current_index])
  e.name = name
  return e
}

function init_location_table(i, t) {
  var l, k, e
  for (l in locations.tract)
    if (Object.prototype.hasOwnProperty.call(locations.tract, l)) {
      t.innerHTML = ''
      for (k in locations.tract[l])
        if (Object.prototype.hasOwnProperty.call(locations.tract[l], k) && k !== 'name') {
          e = document.createElement('tr')
          e.appendChild(document.createElement('td'))
          e.firstElementChild.innerText = k
          e.appendChild(document.createElement('td'))
          t.appendChild(e)
        }
      break
    }
}

function init_measure_table(i, t) {
  const c = measures[_s.variable].components[_s.shapes] || [],
    n = c.length
  var e, i
  t.innerHTML = ''
  e = document.createElement('tr')
  e.appendChild(document.createElement('td'))
  e.firstElementChild.innerText = 'Score'
  e.appendChild(document.createElement('td'))
  t.appendChild(e)
  for (i = 0; i < n; i++)
    if (Object.prototype.hasOwnProperty.call(measures, c[i])) {
      e = document.createElement('tr')
      e.appendChild(document.createElement('td'))
      e.appendChild(document.createElement('td'))
      t.appendChild(e)
      e.firstElementChild.appendChild((e = document.createElement('button')))
      e.value = c[i]
      e.className = 'btn btn-link btn-sm'
      e.innerText = measures[c[i]].name
      e.onclick = _u.variable.set.bind(null, c[i], false)
    } else {
      console.log(c[i])
    }
}

function init_legend(e) {
  e.innerHTML = ''
  for (var i = 0, n = 10; i < n; i++) {
    e.appendChild(document.createElement('span'))
    e.lastElementChild.style.background = pal(i / n)
  }
}

const updaters = {
    selection: function () {
      const d = data[_s.shapes],
        sel = _s.scale === 'county' ? 'county_name' : 'health_district'
      var id, i
      sorted_layers = []
      selected_layers = {}
      for (id in d)
        if (Object.prototype.hasOwnProperty.call(d, id)) {
          if (
            typeof d[id][_s.variable][_u.year.current_index] === 'number' &&
            (_s[_s.scale] === 'All' || locations[_s.shapes][id][sel] === _s[_s.scale]) &&
            (_s.region_type === 'All' || locations[_s.shapes][id].region_type === _s.region_type)
          ) {
            i = sorted_layers.length
            if (!i || d[id][_s.variable][_u.year.current_index] > sorted_layers[i - 1].data[_u.year.current_index]) {
              sorted_layers.push({id: id, data: d[id][_s.variable]})
            } else {
              for (; i--; ) {
                if (d[id][_s.variable][_u.year.current_index] > sorted_layers[i].data[_u.year.current_index]) {
                  sorted_layers.splice(i + 1, 0, {id: id, data: d[id][_s.variable]})
                  break
                }
              }
              if (i === -1) {
                sorted_layers.splice(0, 0, {id: id, data: d[id][_s.variable]})
              }
            }
          }
        }
      function select(i, n) {
        for (; i < n; i++) {
          sorted_layers[i].index = i
          selected_layers[sorted_layers[i].id] = sorted_layers[i]
        }
      }
      select(0, Math.min(5, sorted_layers.length))
      if (sorted_layers.length > 5) select(Math.max(5, sorted_layers.length - 5), sorted_layers.length)
    },
    info: function (id) {
      const m = measures[_s.variable]
      var p, l, i, d
      if (this.variable !== _s.variable) {
        init_measure_table(0, this.temp.children[4])
        init_measure_table(0, this.base.children[4])
        this.variable = _s.variable
      }
      if (id) {
        // hover information
        if (Object.prototype.hasOwnProperty.call(locations[_s.shapes], id)) {
          l = locations[_s.shapes][id]
          d = data[_s.shapes][id]
          p = this.temp.children
          p[0].innerText = l.name
          for (i = p[2].childElementCount; i--; ) {
            if (Object.prototype.hasOwnProperty.call(l, p[2].children[i].firstElementChild.innerText)) {
              p[2].children[i].classList.remove('hidden')
              p[2].children[i].lastElementChild.innerText = l[p[2].children[i].firstElementChild.innerText]
            } else {
              p[2].children[i].classList.add('hidden')
            }
          }
          p[4].firstElementChild.lastElementChild.innerText = d[_s.variable][_u.year.current_index]
          for (i = p[4].childElementCount; i--; ) {
            if (
              p[4].children[i].firstElementChild.firstElementChild &&
              Object.prototype.hasOwnProperty.call(d, p[4].children[i].firstElementChild.firstElementChild.value)
            ) {
              p[4].children[i].lastElementChild.innerText =
                d[p[4].children[i].firstElementChild.firstElementChild.value][_u.year.current_index]
            }
          }
        }
      } else {
        // base information
        p = this.base.children
        p[3].innerText = m.name
        this.temp.children[3].innerText = m.name
        if (_s[_s.scale] === 'All') {
          // when showing all regions
          p[0].innerText = this.defaults.title
          p[4].firstElementChild.lastElementChild.innerText = m.summaries[_s.scale].mean[_u.year.current_index]
          for (i = p[4].childElementCount; i--; ) {
            if (
              p[4].children[i].firstElementChild.firstElementChild &&
              Object.prototype.hasOwnProperty.call(measures, p[4].children[i].firstElementChild.firstElementChild.value)
            ) {
              p[4].children[i].lastElementChild.innerText =
                measures[p[4].children[i].firstElementChild.firstElementChild.value].summaries[_s.shapes].mean[
                  _u.year.current_index
                ]
            }
          }
          p[1].classList.remove('hidden')
          p[2].classList.add('hidden')
        } else {
          // when showing a selected region
          l = locationsByName[_s.scale][_s[_s.scale]]
          d = data[_s.scale][l.id]
          p[0].innerText = l.name
          p[4].firstElementChild.lastElementChild.innerText = d[_s.variable][_u.year.current_index]
          for (i = p[2].childElementCount; i--; ) {
            if (Object.prototype.hasOwnProperty.call(l, p[2].children[i].firstElementChild.innerText)) {
              p[2].children[i].classList.remove('hidden')
              p[2].children[i].lastElementChild.innerText = l[p[2].children[i].firstElementChild.innerText]
            } else {
              p[2].children[i].classList.add('hidden')
            }
          }
          for (i = p[4].childElementCount; i--; ) {
            if (
              p[4].children[i].firstElementChild.firstElementChild &&
              Object.prototype.hasOwnProperty.call(d, p[4].children[i].firstElementChild.firstElementChild.value)
            ) {
              p[4].children[i].lastElementChild.innerText =
                d[p[4].children[i].firstElementChild.firstElementChild.value][_u.year.current_index]
            }
          }
          p[2].classList.remove('hidden')
          p[1].classList.add('hidden')
        }
        this.base.classList.remove('hidden')
        this.temp.classList.add('hidden')
      }
    },
    polygons: function () {
      const all = _s[_s.scale] === 'All'
      var k, layer
      if (all) {
        page.map.flyToBounds(default_bounds)
      } else {
        page.map.flyToBounds(
          page.map.layerManager._byLayerId['shape\n' + locationsByName[_s.scale][_s[_s.scale]].id].getBounds()
        )
      }
      for (k in page.map.layerManager._byLayerId)
        if (Object.prototype.hasOwnProperty.call(page.map.layerManager._byLayerId, k)) {
          layer = page.map.layerManager._byLayerId[k]
          if (layer.options.group === _s.shapes) {
            if (
              all ||
              _s[_s.scale] ===
                locations[layer.options.group][layer.options.layerId][
                  _s.scale === 'county' ? 'county_name' : 'health_district'
                ]
            ) {
              layer.setStyle({
                fillColor: pal(
                  data[layer.options.group][layer.options.layerId][_s.variable][_u.year.current_index],
                  !Object.prototype.hasOwnProperty.call(selected_layers, layer.options.layerId)
                ),
                weight: 1,
              })
              layer.addTo(page.map)
              continue
            }
          }
          layer.remove()
        }
    },
    plot_main: function () {
      const s = measures[_s.variable].summaries[_s.shapes]
      var id,
        i,
        traces = []
      for (id in selected_layers)
        if (Object.prototype.hasOwnProperty.call(selected_layers, id)) {
          traces.push(make_data_entry(_s.shapes, id, _s.variable, locations[_s.shapes][id].name))
        }
      for (i = page.plots[0].data.length; i--; ) {
        if (page.plots[0].data[i].type === 'box') {
          page.plots[0].data[i].x = meta.years
          delete page.plots[0].data[i].y
          page.plots[0].data[i].upperfence = s.max
          page.plots[0].data[i].q3 = s.q3
          page.plots[0].data[i].median = s.median
          page.plots[0].data[i].q1 = s.q1
          page.plots[0].data[i].lowerfence = s.min
          traces.push(page.plots[0].data[i])
          break
        }
      }
      page.plots[0].layout.yaxis.title.text = measures[_s.variable].name
      Plotly.react(page.plots[0], traces, page.plots[0].layout)
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
    buttongroup: function (v, passive) {
      if (this.current !== v && this.values.indexOf(v) !== -1) {
        $.each(
          this.options,
          function (i, e) {
            if (e.value === v) {
              e.checked = true
              e.parentElement.classList.add('active')
              this.update(v, i, passive)
            } else {
              e.parentElement.classList.remove('active')
            }
          }.bind(this)
        )
      }
    },
    radio: function (v, passive) {
      if (this.current !== v && this.values.indexOf(v) !== -1) {
        $.each(
          this.options,
          function (i, e) {
            if (e.value === v) {
              e.checked = true
              this.update(v, i, passive)
            }
          }.bind(this)
        )
      }
    },
    select: function (v, passive) {
      if (this.current !== v) {
        const i = this.values.indexOf(v)
        if (i !== -1) {
          this.e.selectedIndex = i
          this.update(v, i, passive)
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
  },
  data_url = 'https://raw.githubusercontent.com/uva-bi-sdad/VDH/main/src/dashboard/app/assets/data.json'

function update() {
  if (_s.scale === 'county' && _s.shapes === 'district') {
    _u.shapes.set('county', true)
    _u.shapes.e.firstElementChild.disabled = true
  } else {
    _u.shapes.e.firstElementChild.disabled = false
  }
  if (_s.scale === 'county' && _s.county !== 'All') {
    _u.district.set(locationsByName.county[_s.county].health_district, true)
  }
  updaters.selection()
  _u.summary.update()
  updaters.polygons()
  updaters.plot_main()
}

function init() {
  // make inverted location object
  var g, k, i
  for (g in locations)
    if (Object.prototype.hasOwnProperty.call(locations, g)) {
      locationsByName[g] = {All: {id: ''}}
      for (k in locations[g])
        if (Object.prototype.hasOwnProperty.call(locations[g], k)) {
          locationsByName[g][locations[g][k].name] = locations[g][k]
        }
    }

  // make standard years array
  meta.years = []
  for (i = meta.year_range[0]; i <= meta.year_range[1]; i++) meta.years.push(i)

  // make variable and level name map
  for (k in measures)
    if (Object.prototype.hasOwnProperty.call(measures, k)) {
      measureByDisplay[measures[k].name] = k
    }

  // identify page components
  page.map = $('.leaflet')[0].htmlwidget_data_init_result.getMap()
  default_bounds = page.map.getBounds()

  // retrieve plot elements
  $('.plotly').each(function (i, e) {
    if (e.on) {
      page.plots.push(e)
      e.on('plotly_hover', function (d) {
        if (d.points && d.points.length === 1 && page.plots[0].data[d.points[0].fullData.index]) {
          page.plots[0].data[d.points[0].fullData.index].line.width = 4
          Plotly.react(page.plots[0], page.plots[0].data, page.plots[0].layout)
          page.map.layerManager._byLayerId['shape\n' + locationsByName[_s.shapes][d.points[0].text].id].setStyle({
            weight: 3,
          })
          _u.summary.show(locationsByName[_s.shapes][d.points[0].text].id)
        }
      })
        .on('plotly_unhover', function (d) {
          if (d.points && d.points.length === 1 && page.plots[0].data[d.points[0].fullData.index]) {
            page.plots[0].data[d.points[0].fullData.index].line.width = 2
            Plotly.react(page.plots[0], page.plots[0].data, page.plots[0].layout)
            page.map.layerManager._byLayerId['shape\n' + locationsByName[_s.shapes][d.points[0].text].id].setStyle({
              weight: 1,
            })
            _u.summary.revert()
          }
        })
        .on('plotly_click', function (d) {
          if (d.points && d.points.length === 1 && _s.shapes !== 'tract') {
            _u.scale.set(_s.shapes, true)
            _u[_s.shapes].set(d.points[0].text)
          }
        })
    }
  })
  trace_template = JSON.stringify(page.plots[0].data[0])

  // add interaction functions to region shapes
  function add_layer_listeners(name, layer) {
    layer.on({
      mouseover: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId')) {
          e.target.setStyle({
            weight: 3,
          })
          var trace = make_data_entry(
            e.target.options.group,
            e.target.options.layerId,
            _s.variable,
            'hover_line',
            '#000'
          )
          trace.line.width = 4
          Plotly.addTraces(page.plots[0], trace, page.plots[0].data.length)
          _u.summary.show(e.target.options.layerId)
        }
      },
      mouseout: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId')) {
          e.target.setStyle({
            weight: 1,
          })
          if (page.plots[0].data[page.plots[0].data.length - 1].name === 'hover_line')
            Plotly.deleteTraces(page.plots[0], page.plots[0].data.length - 1)
          _u.summary.revert()
        }
      },
      click: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId') && e.target.options.group !== 'tract') {
          _s.selected_layer = e.target.options.layerId
          _u.scale.set(e.target.options.group, true)
          _u[e.target.options.group].set(locations[e.target.options.group][e.target.options.layerId].name)
        }
      },
    })
  }
  $.each(page.map.layerManager._byLayerId, add_layer_listeners)

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
    if (Object.prototype.hasOwnProperty.call(setters, o.type)) {
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
    }
  })

  $('.auto-output').each(function (i, e) {
    var o = {
      type: e.getAttribute('auto-type'),
      id: e.id,
      base: e.firstElementChild,
      temp: e.children[1],
      variable: _s.variable,
      defaults: {
        title: e.firstElementChild.children[0].innerText,
        message: e.firstElementChild.children[1].innerText1,
      },
      show: function (id) {
        this.update(id)
        this.base.classList.add('hidden')
        this.temp.classList.remove('hidden')
      },
      revert: function () {
        this.base.classList.remove('hidden')
        this.temp.classList.add('hidden')
      },
    }
    if (Object.prototype.hasOwnProperty.call(updaters, o.type)) {
      o.update = updaters[o.type].bind(o)
    }
    _u[e.id] = o
    if (o.type === 'info') {
      o.temp.children[1].classList.add('hidden')
      $('.location-table', e).each(init_location_table)
      $('.measure-table', e).each(init_measure_table)
    }
  })

  // initialize legend
  init_legend($('.legend-scale')[0])

  setTimeout(update, 0)
}

function queue_init() {
  if (document.readyState !== 'loading') {
    init()
  } else {
    setTimeout(queue_init, 5)
  }
}

function load_data(url) {
  $.ajax(url, {
    success: function (d) {
      data = JSON.parse(d)
      queue_init()
    },
    error: function (e) {
      console.log('load_data failed', e)
    },
  })
}

load_data(data_url)
