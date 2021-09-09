"use strict"
var client_options = {
    scale: "Health District",
    shapes: "Health District",
    variable: "Health Access",
    district: "All",
    county: "All",
    year_index: 4
  },
  current_options = {},
  locationsByName = {},
  default_bounds = {},
  plots = [],
  page = {}

function pal(value, group){
  const colors = ['#ffffe5', '#fff7bc', '#fee391', '#fec44f', '#fe9929', '#ec7014', '#cc4c02', '#993404', '#662506'],
    range = measures[client_options.variable].ranges[group]
  return colors[
    Math.max(0,
      Math.min(
        colors.length - 1,
        Math.ceil((colors.length - 1) * (value + range[0]) / (range[0] + range[1]))
      )
    )
  ]
}

function make_data_entry(group, id, variable, name, color){
  const d = features[group][id], c = client_options
  for(var i = d[variable].length, e = {
    name: name || "hover_line",
    type: "line",
    data: [],
    itemStyle: {color: color},
    lineStyle: {color: color}
  }; i--;){
    e.data[i] = {value: [d.year[i] + "", d[variable][i]]}
  }
  if(!color) e.itemStyle.color = e.lineStyle.color = pal(d[variable][c.year_index], group)
  return e
}

const varnames = Object.keys(measures), update_map = {
  scale: "select_scale",
  county: "select_region",
  district: "select_region",
  year: "select_year"
}, updaters = {
  polygons: function(){
    $.each(page.map.layerManager._byLayerId, function(name, layer){
      if(layer.options.group === client_options.shapes){
        const d = features[layer.options.group][layer.options.layerId],
          l = locations[layer.options.group][layer.options.layerId],
          s = client_options.scale === "County" ? "county" : "district"
        if(client_options[s] === "All" ||
          client_options[s] === l[s === "county" ? "county_name" : "health_district"]){
          layer.setStyle({
            fillColor: pal(
              d[measures[client_options.variable].name][client_options.year_index],
              layer.options.group
            ),
            weight: 1,
            fillOpacity: 0.7
          })
          layer.addTo(page.map)
          return void 0
        }
      }
      layer.remove()
    })
  },
  map_legend: function(){
    page.map.controls._controlsById.legend._container.firstElementChild.innerHTML =
      "<strong>" + client_options.variable + " Score</strong>"
  },
  plot_main: function(){
    const c = client_options, data = features[c.shapes], variable = measures[c.variable].name,
      type = c.scale === "County" ? "county" : "district"
    var id, i, l, opts = plots[0].getOption(), top = [], bottom = [], all
    opts.series = []
    function top_to_series(e, base, adj){
      for(var i = e.length, ny = meta.year_range[1] - meta.year_range[0] + 1; i--;){
        base.series.splice(-1, 0, make_data_entry(
          c.shapes, e[i].id, variable, locations[c.shapes][e[i].id].name
        ))
      }
    }
    for(id in data) if(Object.prototype.hasOwnProperty.call(data, id)){
      if(c[type] === "All" ||
        locations[c.shapes][id][type === "county" ? "county_name" : "health_district"] === c[type]){
        if(!top.length){
          top.push({id: id, data: data[id][variable]})
        }else{
          for(i = top.length; i--;){
            if(data[id][variable][c.year_index] > top[i].data[c.year_index]){
              top.splice(i + 1, 0, {id: id, data: data[id][variable]})
              break
            }
          }
        }
        if(!bottom.length){
          bottom.push({id: id, data: data[id][variable]})
        }else{
          for(i = bottom.length; i--;){
            if(data[id][variable][c.year_index] < bottom[i].data[c.year_index]){
              bottom.splice(i + 1, 0, {id: id, data: data[id][variable]})
              break
            }
          }
        }
      }
    }
    top_to_series(top.splice(top.length - 5, 5), opts, 5)
    top_to_series(bottom.splice(bottom.length - 5, 5), opts, 0)
    plots[0].setOption(opts, {replaceMerge: "series"})
  },
  select_scale: function(){
    $.each(page.menu.scale.children, function(i, e){
      if(e.innerText === client_options.scale){
        e.classList.add('active')
        e.children[0].checked = true
        page.menu.district.parentElement.parentElement.classList[
          "Health District" === client_options.scale ? "remove" : "add"
        ]("hidden")
        page.menu.county.parentElement.parentElement.classList[
          "County" === client_options.scale ? "remove" : "add"
        ]("hidden")
      }else{
        e.classList.remove('active')
      }
    })
    if(client_options.scale === "County" && client_options.shapes === "Health District"){
      client_options.shapes = "County"
      updaters.menu()
    }
    updaters.polygons()
    updaters.plot_main()
  },
  select_region: function(){
    var internal_type = client_options.scale === "County" ? "county" : "district",
      selected
    page.menu[internal_type].selectedIndex =
      locations[client_options.scale].levels.indexOf(client_options[internal_type])
    if(client_options.selected_layer){
      selected = "shape\n" + client_options.selected_layer
      $.each(page.map.layerManager._byLayerId, function(name, layer){
        if(name === selected){
          if(!page.map.hasLayer(layer)) page.map.addLayer(layer)
          if(internal_type === "county") client_options.district =
            locations[layer.options.group][layer.options.layerId].health_district
          page.map.flyToBounds(layer.getBounds())
        }else{
          page.map.removeLayer(layer)
        }
      })
    }else{
      $.each(page.map.layerManager._byLayerId, function(name, layer){
        if(!page.map.hasLayer(layer)) page.map.addLayer(layer)
      })
      page.map.flyToBounds(default_bounds)
    }
    updaters.polygons()
    updaters.plot_main()
  },
  select_year: function(){
    page.menu.year.selectedIndex = client_options.year_index
  },
  menu: function(){
    $.each(update_map, function(setting, fun){
      if(client_options[setting] !== current_options[setting]) updaters[fun]()
    })
    current_options = JSON.parse(JSON.stringify(client_options))
  }
}, interactions = {
  change_year: function(e){
    client_options.year_index = e.selectedIndex
    updaters.polygons()
    updaters.plot_main()
  },
  change_variable: function(e){
    client_options.variable = varnames[e.selectedIndex]
    updaters.map_legend()
    updaters.polygons()
    updaters.plot_main()
  },
  change_shapes: function(e){
    client_options.shapes = e.children[e.selectedIndex].innerText
    if(client_options.shapes === "Health District" && client_options.scale === "County"){
      client_options.scale = "Health District"
      current_options.District = "none"
    }
    updaters.menu()
    updaters.polygons()
    updaters.plot_main()
  },
  change_region: function(type){
    var internal_type = type === "Health District" ? "district" : "county"
    client_options.selected_layer = locationsByName[type][client_options[internal_type]].id
    current_options[internal_type] = "none"
    client_options.scale = type
    updaters.menu()
  },
  change_selection: function(e, type){
    var internal_type = type === "Health District" ? "district" : "county"
    client_options[internal_type] = locations[type].levels[e.selectedIndex]
    client_options.selected_layer = locationsByName[type][client_options[internal_type]].id
    updaters.menu()
  },
  reset_district: function(){
    if(client_options.district !== "All"){
      client_options.district = "All"
      client_options.selected_layer = ""
      updaters.menu()
    }
  },
  reset_county: function(){
    if(client_options.county !== "All"){
      client_options.county = "All"
      client_options.selected_layer = ""
      updaters.menu()
    }
  }
}

window.onload = function(){
  // make inverted locations object
  var g, k, year_inputs = $("#select_year div")
  for(g in locations) if(Object.prototype.hasOwnProperty.call(locations, g)){
    locationsByName[g] = {All: {id: ""}}
    for(k in locations[g]) if(Object.prototype.hasOwnProperty.call(locations[g], k)){
      locationsByName[g][locations[g][k].name] = locations[g][k]
    }
  }

  // identify page components
  page.map = $('.leaflet')[0].htmlwidget_data_init_result.getMap()
  default_bounds = page.map.getBounds()
  page.menu = {
    scale: $('#select_scale')[0],
    district: $('#select_district')[0],
    county: $('#select_county')[0],
    shapes: $("#select_shapes")[0],
    year: $("#select_year")[0]
  }
  
  // set initial year
  updaters.select_year()
  
  // update menu with initial options after initial layout
  setTimeout(updaters.menu, 0)

  // apply initial map colors
  updaters.polygons()

  // retrieve plot instances from dom
  $('.echarts4r').each(function(i, p){
    plots.push(echarts.getInstanceByDom(p))
  })
  
  // add listener to layer controls
  year_inputs.on("click", interactions.change_year)
  
  // add interaction functions to region shapes
  function add_layer_listeners(name, layer){
    layer.on({
      mouseover: function(e){
        if(Object.prototype.hasOwnProperty.call(e.target.options, "layerId")){
          e.target.setStyle({
            weight: 2,
            fillOpacity: 1
          })
          var opts = plots[0].getOption()
          opts.series.push(make_data_entry(
            e.target.options.group,
            e.target.options.layerId,
            measures[client_options.variable].name,
            "hover_line",
            "#000"
          ))
          opts.series[opts.series.length - 1].lineStyle.width = 3
          plots[0].setOption(opts, false)
        }
      },
      mouseout: function(e){
        if(Object.prototype.hasOwnProperty.call(e.target.options, "layerId")){
          e.target.setStyle({
            weight: 1,
            fillOpacity: 0.7
          })
          var opts = plots[0].getOption()
          if(opts.series[opts.series.length - 1].name === "hover_line"){
            opts.series.splice(opts.series.length - 1, 1)
            plots[0].setOption(opts, true)
          }
        }
      },
      click: function(e){
        if(
          Object.prototype.hasOwnProperty.call(e.target.options, "layerId"),
          e.target.options.group !== "Census Tract"
        ){
          client_options.selected_layer = e.target.options.layerId
          client_options[e.target.options.group === "County" ? "county" : "district"] =
            locations[client_options.shapes][client_options.selected_layer].name
          client_options.scale = e.target.options.group
          updaters.menu()
        }
      }
    })
  }
  $.each(page.map.layerManager._byLayerId, add_layer_listeners)
}
