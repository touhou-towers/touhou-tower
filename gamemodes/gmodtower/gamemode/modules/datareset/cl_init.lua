net.Receive("SendDataReset",function()
  Derma_Query("It looks like you've played GMod Tower before, would you like to keep your old save data, or do you want to start fresh?",
    "GMTC Data Reset",
    "KEEP MY DATA",
    function() end,
    "RESET MY DATA",
    function()
      Derma_Query("Are you absolutely sure? This will reset your GMC, inventory, achievements and suite!",
        "GMTC Data Reset",
        "I AM SURE",
        function()
          RunConsoleCommand('gmt_resetdata')
        end,
        "NO",
        function() end)
    end)
end)
