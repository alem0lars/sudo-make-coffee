require 'rubygems'
require 'yaml'
require 'pathname'
require 'ap'

FILE_ABS_PTH = File.expand_path(__FILE__)
FILE_DIR_PTH = File.dirname(FILE_ABS_PTH)
$:.unshift FILE_DIR_PTH
require 'src/code/bot'
require 'src/code/channel_info'
require 'src/code/ipc/spec/msgs'
require 'src/code/plugins/notifier'
require 'src/lib/ipc/channel'
require 'src/lib/ipc/db'
require 'src/lib/ipc/publisher'
require 'src/lib/ipc/subscriber'


task :default do
  puts 'Available tasks:'
  puts `rake -T`
end

desc 'send a logging message to the specified ipc channel'
task :logging_msg, [:channel, :value] do |t, args|
  cfg = TasksUtils.load_cfg

  db = Ipc::Db.new(cfg['ipc']['db']['host'], cfg['ipc']['db']['port'], cfg['ipc']['db']['nsid'])

  # create ipc channels
  ipc_chans = TasksUtils.load_ipc_chans(cfg)

  # { send the quit msg to each irc channel
  ipc_chan = Ipc::Channel.lookup_name(ipc_chans, "#{db.nsid}:#{args.channel}")
  pub = Ipc::Publisher.new(db, ipc_chan)
  pub.publish(Ipc::Spec::Msgs.instance.logging(args.value))
  # }

  TasksUtils.reset_botpid
end

desc 'start the Sudo Make Coffee bot'
task :start do
  bot = TasksUtils.create_bot
  TasksUtils.save_botpid
  bot.start
end

desc 'stop the bot'
task :stop do
  cfg = TasksUtils.load_cfg
  db = Ipc::Db.new(cfg['ipc']['db']['host'], cfg['ipc']['db']['port'], cfg['ipc']['db']['nsid'])

  # create ipc channels
  ipc_chans = TasksUtils.load_ipc_chans(cfg)

  # { send the quit msg to each irc channel
  ipc_chan_all = Ipc::Channel.lookup_name(ipc_chans, "#{db.nsid}:all")
  pub = Ipc::Publisher.new(db, ipc_chan_all)
  pub.publish(Ipc::Spec::Msgs.instance.quit)
  # }

  TasksUtils.reset_botpid
end

desc 'debugging monitor'
task :monitor do
  cfg = TasksUtils.load_cfg
  db = Ipc::Db.new(cfg['ipc']['db']['host'], cfg['ipc']['db']['port'], cfg['ipc']['db']['nsid'])

  # create ipc channels
  ipc_chans = TasksUtils.load_ipc_chans(cfg)

  # { monitor all ipc channels
  sub = Ipc::Subscriber.new(db, ipc_chans)
  puts '>> Monitor started'
  sub.subscribe do |chan, msg|
    puts ">> [msg]"
    ap msg, :indent => -2
    puts "-- [chan]"
    ap chan, :indent => -2
  end
  # }

end

module TasksUtils

  # create and return the Sudo Make Coffee bot
  def self.create_bot
    # load configurations
    cfg = TasksUtils.load_cfg
    # create the db
    db = Ipc::Db.new(cfg['ipc']['db']['host'], cfg['ipc']['db']['port'], cfg['ipc']['db']['nsid'])
    # create ipc channels
    ipc_chans = TasksUtils.load_ipc_chans(cfg)
    # create irc channels
    irc_chans_info = TasksUtils.load_irc_chans_info(cfg, ipc_chans)
    # create and return the bot
    bot = SudoMakeCoffee::Bot.new(cfg['irc']['server'], irc_chans_info, db, ipc_chans)
  end

  # create a file with the current pid in the tmp/pids directory
  def self.save_botpid
    pid_pth = Pathname.new File.join(FILE_DIR_PTH, 'tmp', 'pids', 'bot.pid')
    File.open(pid_pth, 'w') { |pid_file| pid_file.write($$) }
  end

  # reset the pid file
  def self.reset_botpid
    pid_pth = Pathname.new File.join(FILE_DIR_PTH, 'tmp', 'pids', 'bot.pid')
    File.open(pid_pth, 'w') { }
  end

  # load the configuration and return it as Hash
  def self.load_cfg
    cfg_pth = Pathname.new File.join(FILE_DIR_PTH, 'src', 'data', 'cfg.yaml')
    cfg = nil
    File.open(cfg_pth) do |cfg_file|
      cfg = YAML.load(cfg_file.read)
    end
    cfg # return
  end

  def self.load_ipc_chans cfg
    qualified_name = lambda do |name| "#{cfg['ipc']['db']['nsid']}:#{name}" end
    ipc_chans = cfg['ipc']['channels'].collect do |ipc_chan|
      ipc_chan['name'] = qualified_name.call(ipc_chan['name']) # qualify the current ipc channel
      Ipc::Channel.new(ipc_chan['name'], ipc_chan['format'])
    end
    ipc_chans.push Ipc::Channel.new(qualified_name.call('all'), 'json')
    ipc_chans # return
  end

  def self.load_irc_chans_info cfg, ipc_chans
    qualified_name = lambda do |name| "#{cfg['ipc']['db']['nsid']}:#{name}" end
    irc_chans = cfg['irc']['channels'].collect do |irc_chan|
      irc_chan['ipc_chans'] = irc_chan['ipc_chans'].collect do |ipc_chan_name| # qualify ipc channels associated with the current irc channel
        qualified_name.call(ipc_chan_name)
      end
      ipc_chans_assoc = irc_chan['ipc_chans'].collect do |ipc_chan_name| # retrieve the associated ipc channels objects
        Ipc::Channel.lookup_name(ipc_chans, ipc_chan_name)
      end
      ipc_chans_assoc.push Ipc::Channel.lookup_name(ipc_chans, qualified_name.call('all'))
      Irc::ChannelInfo.new(irc_chan['name'], ipc_chans_assoc) # create a new channel info
    end
    irc_chans # return
  end

end
