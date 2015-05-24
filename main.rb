require 'rubygems'
require 'sinatra'
require 'pry'

#set :sessions, true

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'yjdfh432'

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do
  def calculate_total(cards)
    sum = 0
    card_without_suit = cards.map { |card| card[1] }

    card_without_suit.each do |card|
      if card == 'ace'
        sum += 11
      elsif %w(jack king queen).include?(card)
        sum += 10
      else
        sum += card.to_i
      end
    end

    card_without_suit.count('ace').times do
      sum -= 10 if sum > 21
    end

    sum
  end

  def card_image(card)
    "<img src='/images/cards/#{card[0]}_#{card[1]}.jpg' class='card_image' />"
  end

  def once_again
    @once_again = true
  end

  def show_player_hit_stay_button?
    @show_player_hit_stay == true
  end

  def show_dealer_hit_button?
    @show_dealer_hit == true
  end

  def player_turn?
    session[:turn] == session[:player_name]
  end

  def dealer_turn?
    session[:turn] == session[:dealer_name]
  end

  def loser!(msg)
    @show_player_hit_stay = false
    @error = "<strong>#{session[:player_name]} loses.</strong> #{msg}"
    once_again
  end

  def winner!(msg)
    @show_player_hit_stay = false
    @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
    once_again
  end

  def tie!(msg)
    @show_player_hit_stay = false
    @success = "<strong>It's a tie!</strong> #{msg}"
    once_again
  end

  def cover_dealer_card?
    player_turn? && calculate_total(session[:player_cards]) < BLACKJACK_AMOUNT
  end
end

before do
  @once_again = false
  @show_dealer_hit = false
  @show_player_hit_play = false
end

get '/' do
  if !session[:player_name]
    redirect '/new_player'
  else
    session[:turn] = session[:player_name]
    redirect '/game'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if !params[:player_name].empty?
    session[:player_name] = params[:player_name]
    redirect '/game'
  else
    @error = "Please input your name again!"
    erb :new_player
  end
end

get '/game' do
  suits = %w(diamonds clubs hearts spades)
  cards = %w(ace 2 3 4 5 6 7 8 9 10 jack queen king)
  session[:deck] = suits.product(cards).shuffle!
  session[:dealer_name] = 'Dealer'
  session[:player_cards] = []
  session[:dealer_cards] = []

  2.times do
    session[:player_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
  end

  redirect '/game/play'
end

get '/game/play' do
  if player_turn?
    player_total = calculate_total(session[:player_cards])

    if player_total > BLACKJACK_AMOUNT
      loser!("It looks like #{session[:player_name]} busted at #{player_total}.")
    elsif player_total == BLACKJACK_AMOUNT
      winner!("#{session[:player_name]} hit blackjack at #{player_total}.")
    else
      @show_player_hit_stay = true
    end

  elsif dealer_turn?
    dealer_total = calculate_total(session[:dealer_cards])

    if dealer_total == BLACKJACK_AMOUNT
      loser!("Dealer hit blackjack.")
    elsif dealer_total > BLACKJACK_AMOUNT
      winner!("Dealer busted!.")
    elsif dealer_total >= DEALER_MIN_HIT
      redirect '/game/compare'
    else
      @show_dealer_hit = true
    end

  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  redirect '/game/play'
end

post '/game/player/stay' do
  session[:turn] = session[:dealer_name]
  redirect '/game/play'
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/play'
end

get '/game/compare' do
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total > dealer_total
    winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif player_total < dealer_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:player_name]} and the dealer stayed at #{player_total}.")
  end

  once_again
  erb :game
end

get '/bye' do
  erb :bye
end
