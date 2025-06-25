namespace :onboarding do
  desc "Reseta o onboarding para nova instalação (remove todos os usuários e a chave do Redis) - USE COM CUIDADO!"
  task hard_reset: :environment do
    puts "⚠️  ATENÇÃO: Isso irá remover TODOS os usuários e contas do sistema!"
    print "Digite 'SIM' para continuar: "
    confirm = STDIN.gets.strip
    if confirm == 'SIM'
      puts "Removendo todos os usuários e contas..."
      User.delete_all
      Account.delete_all
      puts "Limpando chave de onboarding no Redis..."
      Redis::Alfred.delete(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)
      puts "✅ Onboarding resetado. Acesse a aplicação para ver o onboarding padrão."
    else
      puts "Operação cancelada."
    end
  end

  desc "Apenas limpa a chave de onboarding no Redis (não remove usuários)"
  task reset_redis: :environment do
    Redis::Alfred.delete(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)
    puts "✅ Chave de onboarding removida do Redis."
  end
end 