def init_db(client)
  begin
    input_sql = ''
    # tableの作成
    File.open(__FILE__[/(.*)data_init.rb/, 1]+"tables.sql", "r:utf-8") do |sql|
      sql.read.split("\n").each do |line|
        if line =~ /.*--.*/
          line = line[/(.*)--.*/, 1]
        end
        input_sql += line.strip + " " if line.strip != ""
      end
    end
    puts input_sql
    client.exec(input_sql)
  rescue SystemCallError => e
    puts %Q(class=[#{e.class}] message=[#{e.message}])
  rescue IOError => e
    puts %Q(class=[#{e.class}] message=[#{e.message}])
  end
end

def insert_fighters(client)
  File.open(__FILE__[/(.*)data_init.rb/, 1]+"fighters", "r:utf-8") do |fighters|
    id = 1
    fighters.each do |fighter|
      fighter.chomp!
      # fighterがinsertされてなければここで実行
      if client.exec_params("SELECT COUNT(*) AS count FROM fighters WHERE name = $1",[fighter])[0]["count"].to_i <= 0
        client.exec_params("INSERT INTO fighters (id, name) SELECT $1, $2;",[id,fighter])
        id += 1
      end
    end
  end
end

def insert_fighters_memo(client, fighter_id, memo)
  memo.gsub!(/(^[[:space:]]+)|([[:space:]]+$)/, '')
  if memo != ""
    client.exec_params("INSERT INTO notes (fighter_id, memo) SELECT $1, $2;",[fighter_id,memo])
  end
end
