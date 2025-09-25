    // name
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "l" },
      "columns": [
        { "type": "columnproperty", "size": { "mode": "flex" , "value": 1 }, "align": "l" },
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        { "type": "columnproperty", "size": { "mode": "flex" , "value": 1 }, "align": "l" },
      ],
      "rows": [
        [
          { "type": "repeat", "value": "─", "styles": [{ "$ref": "#/styles/title" }] },
          { "type": "text", "value": "<<cv.name>>", "styles": [{ "$ref": "#/styles/title" }] },
          { "type": "repeat", "value": "─", "styles": [{ "$ref": "#/styles/title" }] },
        ]
      ]
    },
    { "type": "br" },


    // email, phone, website
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "c" },
      "columns": [
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },

        ((* if cv.phone *))
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        ((* endif *))

        ((* if cv.website *))
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        ((* endif *))
      ],
      "rows": [
        [
          { "type": "text", "value": "<<cv.email>>", "styles": [{ "$ref": "#/styles/sec" }, {"type":"style", "link":"mailto:<<cv.email>>"}] },
          
          ((* if cv.phone *))
          { "type": "text", "value": "•" },
          { "type": "text", "value": "<<cv.phone|replace("tel:", "")|replace("-"," ")>>", "styles": [{ "$ref": "#/styles/sec" }, {"type":"style", "link":"<<cv.phone>>"}] },
          ((* endif *))

          ((* if cv.website *))
          { "type": "text", "value": "•" },
          { "type": "text", "value": "<<cv.website|replace("https://","")|replace("/","")>>", "styles": [{ "$ref": "#/styles/sec" }, {"type":"style", "link":"<<cv.website>>"}] },
          ((* endif *))
        ]
      ]
    },
    { "type": "br" },


    // Social Media
    ((* if cv.social_networks *))
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "c" },
      "columns": [
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "l" },
      ],
      "rows": [
        ((* for network in cv.social_networks *))
        [
          { "type": "text", "value": "<<network.network>>", "styles": [{ "$ref": "#/styles/subtitle" }] },
          { "type": "text", "value": "<<network.username>>", "styles": [{ "$ref": "#/styles/prim" }] },
          { "type": "text", "value": "<<network.url>>", "styles": [{ "$ref": "#/styles/sec" }, {"type":"style", "link":"<<network.url>>"}] },
        ],
        ((* endfor *))
      ]
    },
    { "type": "br" },
    ((* endif *))

    // Location
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "c" },
      "columns": [
        { "type": "columnproperty", "size": { "mode": "fixed", "value": 0 }, "align": "c" },
      ],
      "rows": [
        [
          { "type": "text", "value": "<<cv.location>>", "styles": [{ "$ref": "#/styles/sec" }] },
        ]
      ]
    },
    { "type": "br" },


