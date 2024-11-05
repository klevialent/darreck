import Config

config :darreck, Darreck.Scheduler,
  jobs: [
    {"10 11,16,21 * * *",      {DarreckSchedule.PortfolioStat, :run, []}},
  ]
