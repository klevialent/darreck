import Config

config :darreck, Darreck.Scheduler,
  jobs: [
    {"14 11,16 * * *",      {DarreckSchedule.PortfolioStat, :run, []}},
    {"52 20 * * *",         {DarreckSchedule.PortfolioStat, :run, []}},
    {"00 11,16 * * *",      {DarreckSchedule.VarMargin, :set_position_cost, []}},
    {"15 11,16 * * *",      {DarreckSchedule.VarMargin, :set_var_margin, []}},
  ]
