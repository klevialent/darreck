import Config

config :darreck, Darreck.Scheduler,
  jobs: [
    {"10 11,16,21 * * *",      {DarreckSchedule.PortfolioStat, :run, []}},
    {"00 11,16 * * *",      {DarreckSchedule.VarMargin, :set_position_cost, []}},
    {"15 11,16 * * *",      {DarreckSchedule.VarMargin, :set_var_margin, []}},
  ]
