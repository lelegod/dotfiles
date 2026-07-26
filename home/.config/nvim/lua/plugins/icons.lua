return {
  {
    'nvim-mini/mini.icons',
    lazy = false,     
    priority = 900,   
    opts = {},        
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
}
