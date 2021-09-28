'use strict'
const palettes = {
    // from https://colorbrewer2.org
    divergent: ['#1b7837', '#7fbf7b', '#d9f0d3', '#e7d4e8', '#af8dc3', '#762a83'],
    reds: ['#f1eef6', '#d7b5d8', '#df65b0', '#dd1c77', '#980043'],
    greens: ['#ffffcc', '#c2e699', '#78c679', '#31a354', '#006837'],
    greys: ['#f7f7f7', '#cccccc', '#969696', '#525252'],
    cats: ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c'],
  },
  patterns = {
    single_decimal: /(\.\d$)/,
  },
  updaters = {
    selection: function () {
      const l = locations[_s.shapes],
        selected = _s[_s.scale],
        all = selected === 'All'
      selected_layers = {}
      if (viewid !== _s.region_type + _s.shapes + _s.scale + _s.variable) calculate_summaries()
      var i = 0,
        bi = 0,
        o = measures[_s.variable].order[_s.shapes][_u.year.current_index],
        n = Math.min(_s.n_extremes, o.length)
      selected_index = []

      // select from bottom
      if (all) {
        for (; bi < n; bi++) {
          selected_layers[o[bi][0]] = o[bi]
          selected_index.push(bi)
        }
      } else {
        for (; bi < n; bi++) {
          if (selected === l[o[bi][0]][_s.scale]) {
            selected_layers[o[bi][0]] = o[bi]
            selected_index.push(bi)
          } else if (n < o.length) n++
        }
      }

      // select from top
      if (bi < o.length) {
        i = o.length - 1
        n = Math.max(bi, o.length - _s.n_extremes)
        if (all) {
          for (; i > n; i--) {
            selected_layers[o[i][0]] = o[i]
            selected_index.splice(bi, 0, i)
          }
        } else {
          for (; i > n; i--) {
            if (selected === l[o[i][0]][_s.scale]) {
              selected_layers[o[i][0]] = o[i]
              selected_index.splice(bi, 0, i)
            } else if (n > bi) n--
          }
        }
      }
    },
    info: function (id) {
      const m = measures[_s.variable]
      var p, l, e, i, d, n
      if (this.variable !== _s.variable) {
        init_measure_table(this.temp.children[4], true)
        init_measure_table(this.base.children[4])
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
            e = p[2].children[i].firstElementChild.innerText
            if (Object.prototype.hasOwnProperty.call(l, e)) {
              p[2].children[i].classList.remove('hidden')
              p[2].children[i].lastElementChild.innerText = Object.prototype.hasOwnProperty.call(locations, e)
                ? locations[e][l[e]].name
                : l[e]
            } else {
              p[2].children[i].classList.add('hidden')
            }
          }
          p[4].firstElementChild.lastElementChild.innerText = d
            ? format_value(d[_s.variable][_u.year.current_index])
            : 'NA'
          for (i = 1, n = p[4].childElementCount; i < n; i++) {
            if (p[4].children[i].firstElementChild.firstElementChild) {
              if (
                d &&
                Object.prototype.hasOwnProperty.call(d, p[4].children[i].firstElementChild.firstElementChild.value)
              ) {
                p[4].children[i].lastElementChild.innerText = format_value(
                  d[p[4].children[i].firstElementChild.firstElementChild.value][_u.year.current_index]
                )
              } else {
                p[4].children[i].lastElementChild.innerText = 'NA'
              }
            }
          }
        }
      } else {
        // base information
        p = this.base.children
        if (p[3].tagName !== 'DIV') p[3].innerText = m.name
        this.temp.children[3].innerText = m.name
        if (_s[_s.scale] === 'All') {
          // when showing all regions
          p[0].innerText = this.defaults.title
          p[4].firstElementChild.lastElementChild.innerText = format_value(
            m.summaries[_s.scale].mean[_u.year.current_index]
          )
          for (i = p[4].childElementCount; i--; ) {
            if (
              p[4].children[i].firstElementChild.firstElementChild &&
              Object.prototype.hasOwnProperty.call(measures, p[4].children[i].firstElementChild.firstElementChild.value)
            ) {
              p[4].children[i].lastElementChild.innerText = format_value(
                measures[p[4].children[i].firstElementChild.firstElementChild.value].summaries[_s.shapes].mean[
                  _u.year.current_index
                ]
              )
            }
          }
          p[1].classList.remove('hidden')
          p[2].classList.add('hidden')
        } else {
          // when showing a selected region
          l = locations[_s.scale][_s[_s.scale]]
          d = data[_s.scale][l.id]
          p[0].innerText = l.name
          p[4].firstElementChild.lastElementChild.innerText = format_value(d[_s.variable][_u.year.current_index])
          for (i = p[2].childElementCount; i--; ) {
            e = p[2].children[i].firstElementChild.innerText
            if (Object.prototype.hasOwnProperty.call(l, e)) {
              p[2].children[i].classList.remove('hidden')
              p[2].children[i].lastElementChild.innerText = Object.prototype.hasOwnProperty.call(locations, e)
                ? locations[e][l[e]].name
                : l[e]
            } else {
              p[2].children[i].classList.add('hidden')
            }
          }
          for (i = p[4].childElementCount; i--; ) {
            if (
              p[4].children[i].firstElementChild.firstElementChild &&
              Object.prototype.hasOwnProperty.call(d, p[4].children[i].firstElementChild.firstElementChild.value)
            ) {
              p[4].children[i].lastElementChild.innerText = format_value(
                d[p[4].children[i].firstElementChild.firstElementChild.value][_u.year.current_index]
              )
            }
          }
          p[2].classList.remove('hidden')
          p[1].classList.add('hidden')
        }
        this.base.classList.remove('hidden')
        this.temp.classList.add('hidden')
      }
    },
    rank: function () {
      const o = measures[_s.variable].order[_s.shapes],
        m = measures[_s.variable].summaries[_s.shapes],
        d = data[_s.shapes],
        cy = _u.year.current_index,
        ny = meta.years.length,
        n = o[0].length
      this.e.lastElementChild.lastElementChild.innerText = ''
      this.e.lastElementChild.firstElementChild.firstElementChild.firstElementChild.innerText =
        _u.shapes.display[_u.shapes.current_index]
      for (var i = n, id, y, r, ed; i--; )
        if (Object.prototype.hasOwnProperty.call(selected_layers, o[cy][i][0])) {
          id = o[cy][i][0]
          for (y = 0; y < ny; y++) {
            ed = d[id][_s.variable][y]
            r = rank_rows[id].children[y + 1]
            if (!r.firstElementChild.innerText) {
              r.firstElementChild.innerText = format_value(ed)
              r.lastElementChild.style.height = ((ed - m.min[y]) / (m.max[y] - m.min[y])) * 100 + '%'
              r.lastElementChild.style.background = pal(ed, 'divergent')
            }
          }
          this.e.lastElementChild.lastElementChild.appendChild(rank_rows[o[cy][i][0]])
        }
    },
    polygons: function () {
      const all = _s[_s.scale] === 'All',
        all_regions = _s.region_type === 'All'
      var k, layer
      setTimeout(
        page.map.flyToBounds.bind(
          page.map,
          all ? default_bounds : page.map.layerManager._byLayerId['shape\n' + _s[_s.scale]].getBounds()
        ),
        50
      )
      for (k in page.map.layerManager._byLayerId)
        if (Object.prototype.hasOwnProperty.call(page.map.layerManager._byLayerId, k)) {
          layer = page.map.layerManager._byLayerId[k]
          if (
            layer.options.group === _s.shapes &&
            Object.prototype.hasOwnProperty.call(data[layer.options.group], layer.options.layerId)
          ) {
            if (all || _s[_s.scale] === locations[layer.options.group][layer.options.layerId][_s.scale]) {
              colors[layer.options.layerId] = pal(
                data[layer.options.group][layer.options.layerId][_s.variable][_u.year.current_index],
                'divergent'
              )
              layer.setStyle({
                fillColor:
                  all_regions || _s.region_type === locations[_s.shapes][layer.options.layerId].type
                    ? colors[layer.options.layerId]
                    : '#d8d8d8',
                weight: Object.prototype.hasOwnProperty.call(selected_layers, layer.options.layerId) ? 3 : 0.5,
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
      for (var i = this.options.length; i--; )
        if (this.options[i].checked) {
          this.update(this.options[i].value, i, true)
        } else {
          this.options[i].parentElement.classList.remove('active')
        }
      return this.current
    },
    radio: function () {
      for (var i = this.options.length; i--; )
        if (this.options[i].checked) {
          this.update(this.options[i], i, true)
          break
        }
      return this.current
    },
    slider: function () {
      this.update(this.e.value, parseInt(this.e.value) - this.min, true)
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
        for (var i = this.options.length; i--; )
          if (this.options[i].value === v) {
            this.options[i].checked = true
            this.options[i].parentElement.classList.add('active')
            this.update(v, i, passive)
          } else {
            this.options[i].parentElement.classList.remove('active')
          }
      }
    },
    radio: function (v, passive) {
      if (this.current !== v && this.values.indexOf(v) !== -1) {
        for (var i = this.options.length; i--; )
          if (this.options[i].value === v) {
            this.options[i].checked = true
            this.update(v, i, passive)
          }
      }
    },
    slider: function (v, i, passive) {
      if (this.current !== v) {
        this.e.value = v
        this.update(v, i, passive)
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
    slider: function (e) {
      this.update(e.target.value, parseInt(e.target.value) - this.min)
    },
    select: function (e) {
      this.update(e.target.value, e.target.selectedIndex)
    },
  },
  data_url = 'https://raw.githubusercontent.com/uva-bi-sdad/VDH/main/src/dashboard/app/assets/data.json'

var data = {},
  colors = {},
  rank_rows = {},
  locationsByName = {},
  measureByDisplay = {},
  default_bounds = {},
  trace_template = '',
  selected_layers = {},
  selected_index = [],
  viewid = '',
  page = {
    map: null,
    plots: [],
  },
  summary = {},
  _u = {},
  _s = {n_extremes: 10},
  _c = {}

function pal(value, which, normed) {
  const colors = palettes[Object.prototype.hasOwnProperty.call(palettes, which) ? which : 'reds'],
    s = measures[_s.variable].summaries[_s.shapes],
    y = _u.year.current_index,
    min = normed ? 0 : s.min[y],
    max = normed ? 1 : s.max[y],
    nm = normed ? 0.5 : s.norm_median[y]
  return typeof value === 'number'
    ? colors[
        Math.max(
          0,
          Math.min(
            colors.length - 1,
            Math.round(
              which === 'divergent'
                ? 3 + colors.length * ((value - min) / (max - min) - nm)
                : (colors.length * (value - min)) / (max - min)
            )
          )
        )
      ]
    : '#ffffff'
}

function format_value(v) {
  return 'number' === typeof v ? (Math.round(v * 1e2) / 1e2 + '').replace(patterns.single_decimal, '$10') : v
}

function make_data_entry(group, id, variable, name, color) {
  const d = data[group][id]
  for (var i = d[variable].length, e = JSON.parse(trace_template); i--; ) {
    e.text[i] = name
    e.x[i] = d.year[i]
    e.y[i] = d[variable][i]
  }
  e.color = e.line.color = e.marker.color = e.marker.line.color = e.textfont.color = color || colors[id]
  e.name = name
  return e
}

function init_location_table(t) {
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

function init_measure_table(t, temp) {
  var e,
    i,
    c = measures[_s.variable].components[_s.shapes] || [],
    n = c.length
  t.innerHTML = ''
  e = document.createElement('tr')
  e.appendChild(document.createElement('td'))
  e.firstElementChild.innerHTML = '<strong>Score</strong>'
  e.appendChild(document.createElement('td'))
  t.appendChild(e)
  if (n) {
    e = document.createElement('tr')
    e.appendChild(document.createElement('td'))
    e.firstElementChild.colSpan = 2
    e.firstElementChild.innerText = 'Components'
    t.appendChild(e)
    for (i = 0; i < n; i++)
      if (Object.prototype.hasOwnProperty.call(measures, c[i])) {
        e = document.createElement('tr')
        e.appendChild(document.createElement('td'))
        e.appendChild(document.createElement('td'))
        t.appendChild(e)
        e.firstElementChild.appendChild((e = document.createElement(temp ? 'a' : 'button')))
        e.value = c[i]
        e.className = 'btn btn-link btn-sm'
        e.innerText = measures[c[i]].name
        if (!temp) e.onclick = _u.variable.set.bind(null, c[i], false)
      }
  }
  if (
    Object.prototype.hasOwnProperty.call(measures[_s.variable], 'part_of') &&
    Object.prototype.hasOwnProperty.call(measures[_s.variable].part_of, _s.shapes)
  ) {
    e = document.createElement('tr')
    e.appendChild(document.createElement('td'))
    e.firstElementChild.colSpan = 2
    e.firstElementChild.innerText = 'Composites'
    t.appendChild(e)
    c = measures[_s.variable].part_of[_s.shapes]
    if ('string' === typeof c) c = [c]
    for (i = 0, n = c.length; i < n; i++)
      if (Object.prototype.hasOwnProperty.call(measures, c[i])) {
        e = document.createElement('tr')
        e.appendChild(document.createElement('td'))
        e.appendChild(document.createElement('td'))
        t.appendChild(e)
        e.firstElementChild.appendChild((e = document.createElement(temp ? 'a' : 'button')))
        e.value = c[i]
        e.className = 'btn btn-link btn-sm'
        e.innerText = measures[c[i]].name
        if (!temp) e.onclick = _u.variable.set.bind(null, c[i], false)
      }
  }
}

function init_legend(e) {
  e.innerHTML = ''
  for (var i = 0, n = 6; i < n; i++) {
    e.appendChild(document.createElement('span'))
    e.lastElementChild.style.background = pal(i / n, 'divergent', true)
  }
}

function update() {
  if (_s.scale === 'county' && _s.shapes === 'district') {
    _u.shapes.set('county', true)
    _u.shapes.e.firstElementChild.disabled = true
  } else {
    _u.shapes.e.firstElementChild.disabled = false
  }
  if (_s.scale === 'county' && _s.county !== 'All') {
    _u.district.set(locations.county[_s.county].district, true)
  }
  updaters.selection()
  _u.summary.update()
  updaters.polygons()
  updaters.plot_main()
  _u.rank_table.update()
}

function init() {
  // add resize listener to container
  page.header = document.getElementsByClassName('navbar')[0]
  page.menu = document.getElementById('menu')
  page.container = document.getElementById('dashboard-container')
  function resize_container() {
    const hh = page.header.getBoundingClientRect().height + 8,
      mh = page.menu.getBoundingClientRect().height + 8
    page.container.style.top = mh + 'px'
    page.container.style.height = document.body.getBoundingClientRect().height - hh - mh + 'px'
  }
  window.addEventListener('resize', resize_container)

  // make inverted location object
  var g, k, i, e, c, ce, ci, n, o, cond
  for (g in locations)
    if ('meta' !== g && Object.prototype.hasOwnProperty.call(locations, g)) {
      locationsByName[g] = {All: {id: ''}}
      for (k in locations[g])
        if (Object.prototype.hasOwnProperty.call(locations[g], k)) {
          if (g === 'district') {
            locations[g][k].district = locations[g][k].id
          } else {
            locations[g][k].county = locations[g][k].id.substr(0, 5)
            if (g !== 'county') {
              locations[g][k].tract = locations[g][k].id.substr(0, 11)
            }
          }
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
      if (!Object.prototype.hasOwnProperty.call(measures[k], 'components')) {
        measures[k].components = {}
      }
      for (g in locations)
        if ('meta' !== g && Object.prototype.hasOwnProperty.call(locations, g)) {
          if (!Object.prototype.hasOwnProperty.call(measures[k].components, g)) {
            measures[k].components[g] = []
          }
        }
    }

  // identify page components
  page.map = document.getElementsByClassName('leaflet')[0].htmlwidget_data_init_result.getMap()
  default_bounds = page.map.getBounds()

  // retrieve plot elements
  for (c = document.getElementsByClassName('plotly'), i = c.length; i--; ) {
    e = c[i]
    if (e.on) {
      page.plots.push(e)
      e.on('plotly_hover', function (d) {
        if (d.points && d.points.length === 1 && page.plots[0].data[d.points[0].fullData.index]) {
          page.plots[0].data[d.points[0].fullData.index].line.width = 4
          Plotly.react(page.plots[0], page.plots[0].data, page.plots[0].layout)
          _u.summary.show(locationsByName[_s.shapes][d.points[0].text].id)
          var layer = page.map.layerManager._byLayerId['shape\n' + locationsByName[_s.shapes][d.points[0].text].id]
          if (layer._map) {
            layer.setStyle({color: '#ffffff'})
            layer.bringToFront()
          }
        }
      })
        .on('plotly_unhover', function (d) {
          if (d.points && d.points.length === 1 && page.plots[0].data[d.points[0].fullData.index]) {
            page.plots[0].data[d.points[0].fullData.index].line.width = 2
            Plotly.react(page.plots[0], page.plots[0].data, page.plots[0].layout)
            _u.summary.revert()
            var layer = page.map.layerManager._byLayerId['shape\n' + locationsByName[_s.shapes][d.points[0].text].id]
            if (layer._map) layer.setStyle({color: '#000000'})
          }
        })
        .on('plotly_click', function (d) {
          if (d.points && d.points.length === 1 && _s.shapes !== 'tract') {
            _u.scale.set(_s.shapes, true)
            _u[_s.shapes].set(locationsByName[_s.shapes][d.points[0].text].id)
          }
        })
    }
  }
  trace_template = JSON.stringify(page.plots[0].data[0])

  // add interaction functions to region shapes
  function add_layer_listeners(layer) {
    layer.on({
      mouseover: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId')) {
          e.target.setStyle({
            color: '#ffffff',
          })
          e.target.bringToFront()
          if (Object.prototype.hasOwnProperty.call(data[e.target.options.group], e.target.options.layerId)) {
            var trace = make_data_entry(
              e.target.options.group,
              e.target.options.layerId,
              _s.variable,
              'hover_line',
              '#000'
            )
            trace.line.width = 4
            Plotly.addTraces(page.plots[0], trace, page.plots[0].data.length)
          }
          _u.summary.show(e.target.options.layerId)
        }
      },
      mouseout: function (e) {
        if (Object.prototype.hasOwnProperty.call(e.target.options, 'layerId')) {
          if (Object.prototype.hasOwnProperty.call(data[e.target.options.group], e.target.options.layerId)) {
            if (page.plots[0].data[page.plots[0].data.length - 1].name === 'hover_line')
              Plotly.deleteTraces(page.plots[0], page.plots[0].data.length - 1)
          }
          e.target.setStyle({
            color: '#000000',
          })
          _u.summary.revert()
        }
      },
      click: function (e) {
        if (
          Object.prototype.hasOwnProperty.call(e.target.options, 'layerId') &&
          e.target.options.group !== 'tract' &&
          Object.prototype.hasOwnProperty.call(data[e.target.options.group], e.target.options.layerId)
        ) {
          _s.selected_layer = e.target.options.layerId
          _u.scale.set(e.target.options.group, true)
          _u[e.target.options.group].set(e.target.options.layerId)
        }
      },
    })
  }
  for (var k in page.map.layerManager._byLayerId)
    if (Object.prototype.hasOwnProperty.call(page.map.layerManager._byLayerId, k)) {
      add_layer_listeners(page.map.layerManager._byLayerId[k])
    }

  // connect inputs
  for (c = document.getElementsByClassName('auto-input'), i = c.length; i--; ) {
    e = c[i]
    o = {
      type: e.getAttribute('auto-type'),
      id: e.id,
      current: '',
      current_index: -1,
      previous: '',
      e: e,
      values: [],
      display: [],
    }
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
      if (o.type === 'slider') {
        o.values = o.display = o.options = []
        o.min = parseInt(o.e.min)
        o.max = parseInt(o.e.max)
        for (ci = o.min, n = o.max; ci <= n; ci++) {
          o.values.push(ci)
        }
      } else {
        for (ci = e.children.length; ci--; ) {
          o.values[ci] = o.options[ci].value
          o.display[ci] = e.children[ci].innerText.trim() || o.values[ci]
        }
      }

      // add listeners
      if (o.type === 'select' || o.type === 'slider') {
        e.addEventListener('change', o.listen)
        if (e.nextElementSibling && e.nextElementSibling.className === 'input-group-append') {
          e.nextElementSibling.firstElementChild.addEventListener('click', o.reset)
        }
      } else {
        for (ci = o.options.length; ci--; ) o.options[ci].addEventListener('click', o.listen)
      }

      // update display condition
      if ((cond = e.getAttribute('condition'))) {
        if (!Object.prototype.hasOwnProperty.call(_c, cond)) _c[cond] = []
        _c[cond].push(e.id)
        if (Object.prototype.hasOwnProperty.call(_s, cond) && _s[cond] === e.id) {
          e.parentElement.parentElement.classList.remove('hidden')
        }
      }

      // get initial values
      _s[e.id] = o.default = o.get()
    }
  }

  for (c = document.getElementsByClassName('auto-output'), i = c.length; i--; ) {
    e = c[i]
    n = meta.years.length
    o = {
      type: e.getAttribute('auto-type'),
      id: e.id,
      variable: _s.variable,
      e: e,
    }
    if (Object.prototype.hasOwnProperty.call(updaters, o.type)) {
      o.update = updaters[o.type].bind(o)
    }
    _u[e.id] = o
    if (o.type === 'info') {
      o.base = e.firstElementChild
      o.temp = e.children[1]
      o.defaults = {
        title: e.firstElementChild.children[0].innerText,
        message: e.firstElementChild.children[1].innerText1,
      }
      o.show = function (id) {
        this.update(id)
        this.base.classList.add('hidden')
        this.temp.classList.remove('hidden')
      }
      o.revert = function () {
        this.base.classList.remove('hidden')
        this.temp.classList.add('hidden')
      }
      o.temp.children[1].classList.add('hidden')
      for (ce = e.getElementsByClassName('location-table'), ci = ce.length; ci--; ) {
        init_location_table(ce[ci])
      }
      for (ce = e.getElementsByClassName('measure-table'), ci = ce.length; ci--; ) {
        init_measure_table(ce[ci])
      }
    } else if (o.type === 'rank') {
      e.firstElementChild.firstElementChild.appendChild((e = document.createElement('tr')))
      e.appendChild(document.createElement('th'))
      e.lastElementChild.innerText = _u.shapes.display[_u.shapes.current_index]
      for (ci = 0; ci < n; ci++) {
        e.appendChild(document.createElement('th'))
        e.lastElementChild.innerText = meta.years[ci]
      }
    }
  }

  // initialize legend
  init_legend(document.getElementsByClassName('legend-scale')[0])

  setTimeout(update, 0)
  setTimeout(resize_container, 0)
}

function quantile_inds(p, n) {
  var q = [p * (n - 1), 0, 0, 0]
  q[1] = q[0] % 1
  q[2] = 1 - q[1]
  q[3] = Math.ceil(q[0])
  q[0] = Math.floor(q[0])
  return q
}

function init_summaries() {
  var m, measure, s, y
  for (measure in measures)
    if (Object.prototype.hasOwnProperty.call(measures, measure)) {
      m = measures[measure]
      m.summaries = {}
      m.order = {}
      for (s in data) {
        if (Object.prototype.hasOwnProperty.call(data, s)) {
          m.order[s] = []
          m.summaries[s] = {
            max: [],
            q3: [],
            mean: [],
            norm_median: [],
            median: [],
            q1: [],
            min: [],
          }
          for (y = meta.years.length; y--; ) {
            m.order[s].push([])
            m.summaries[s].max.push(-Infinity)
            m.summaries[s].q3.push(0)
            m.summaries[s].mean.push(0)
            m.summaries[s].norm_median.push(0)
            m.summaries[s].median.push(0)
            m.summaries[s].q1.push(0)
            m.summaries[s].min.push(Infinity)
          }
        }
      }
    }
}

function calculate_summaries() {
  viewid = _s.region_type + _s.shapes + _s.scale + _s.variable
  const all_regions = _s.region_type === 'All',
    l = locations[_s.shapes],
    ny = meta.years.length
  var q1,
    q3,
    id,
    y,
    n,
    m,
    e,
    dim,
    mo,
    ms,
    mi,
    ims = [_s.variable, ...measures[_s.variable].components[_s.shapes]],
    measure,
    ds = data[_s.shapes]
  for (mi = ims.length; mi--; )
    if (Object.prototype.hasOwnProperty.call(measures, ims[mi])) {
      measure = ims[mi]
      m = measures[measure]
      mo = m.order[_s.shapes]
      ms = m.summaries[_s.shapes]
      for (y = meta.years.length; y--; ) {
        mo[y] = []
        ms.mean[y] = 0
      }
      n = []
      for (id in ds)
        if (Object.prototype.hasOwnProperty.call(ds, id) && (all_regions || _s.region_type === l[id].type)) {
          dim = ds[id][measure]
          e = rank_rows[id] = document.createElement('tr')
          e.appendChild(document.createElement('td'))
          e.lastElementChild.innerText = l[id].name
          for (y = 0; y < ny; y++) {
            e.appendChild(document.createElement('td'))
            e.lastElementChild.appendChild(document.createElement('span'))
            e.lastElementChild.lastElementChild.className = 'value'
            e.lastElementChild.appendChild(document.createElement('div'))
            e.lastElementChild.lastElementChild.className = 'rank-bar'
            if (!mi) mo[y].push([id, dim[y]])
            if (typeof dim[y] === 'number') {
              if (!n[y]) n[y] = 0
              ms.mean[y] += dim[y]
              n[y]++
            }
          }
        }
      if (!mi)
        for (y = 0; y < ny; y++) {
          mo[y].sort(function sf(a, b) {
            return a[1] - b[1]
          })
        }
      mo = m.order[_s.shapes]
      ms = m.summaries[_s.shapes]
      if (mi) {
        for (y = 0; y < ny; y++) ms.mean[y] = n[y] ? ms.mean[y] / n[y] : 0
      } else {
        for (y = 0; y < ny; y++) {
          if (n[y]) {
            q1 = quantile_inds(0.25, n[y])
            q3 = quantile_inds(0.75, n[y])
            ms.max[y] = mo[y][n[y] - 1][1]
            ms.q3[y] = q3[2] * mo[y][q3[0]][1] + q3[1] * mo[y][q3[3]][1]
            ms.mean[y] = ms.mean[y] / n[y]
            ms.median[y] = mo[y][Math.floor(0.5 * n[y])][1]
            ms.q1[y] = q1[2] * mo[y][q1[0]][1] + q1[1] * mo[y][q1[3]][1]
            ms.min[y] = mo[y][0][1]
          } else {
            ms.max[y] = 1
            ms.q3[y] = 0.75
            ms.mean[y] = 0
            ms.median[y] = 0.5
            ms.q1[y] = 0.25
            ms.min[y] = 0
          }
          ms.norm_median[y] = (ms.median[y] - ms.min[y]) / (ms.max[y] - ms.min[y])
        }
      }
    }
}

function aggregate() {}

function queue_init() {
  if (document.readyState !== 'loading') {
    init()
    init_summaries()
    calculate_summaries()
  } else {
    setTimeout(queue_init, 5)
  }
}

function load_data(url) {
  var f = new XMLHttpRequest()
  f.onreadystatechange = function () {
    if (f.readyState === 4) {
      if (f.status === 200) {
        data = JSON.parse(f.responseText)
        queue_init()
      } else {
        console.log('load_data failed', f.responseText)
      }
    }
  }
  f.open('GET', url, true)
  f.send()
}

load_data(data_url)
