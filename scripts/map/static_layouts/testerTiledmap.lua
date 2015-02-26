return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 5,
  height = 5,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../../../../../../../Users/Jades/Desktop/tileset/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../../../../../../Users/Jades/Desktop/tileset/tiles.png",
      imagewidth = 512,
      imageheight = 128,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 5,
      height = 5,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        6, 6, 6, 6, 6,
        6, 6, 6, 6, 6,
        6, 6, 6, 6, 6,
        6, 6, 6, 6, 6,
        6, 6, 6, 6, 6
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "sktiletroupplepondhotspot",
          shape = "rectangle",
          x = 159,
          y = 158,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sktiletroupplepond",
          shape = "rectangle",
          x = 159,
          y = 158,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
