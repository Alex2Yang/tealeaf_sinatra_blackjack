$(document).ready(function() {
  check_player_name();
  check_player_wager();
  player_hit();
  player_stay();
  dealer_hit();
});

function check_player_name() {
  $(document).on('click','#sumbit_player_name', function() {
    if($('#player_name').val() == "")
  {
    alert("Name is required.")
    $('#player_name').focus();
    return false;
    }
  });
}

function check_player_wager() {
  $(document).on('click','#submit_player_wager', function() {
    var player_wager = parseInt($('#player_wager').val());
    var balance = parseInt($('#balance').text());

    if(isNaN(player_wager) || player_wager <= 0) {
      alert("Bet must be greater than zero.")
      $('#player_wager').focus();
    return false;
    }

    if (player_wager > balance) {
      alert("Bet amount cannot be greater than what you have.")
      $('#player_wager').focus();
      return false;
    }
  });
}

function player_hit() {
  $(document).on('click','#player_hit', function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on('click','#player_stay', function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });
}

function dealer_hit() {
  $(document).on('click','#dealer_hit', function() {
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
  });
  return false;
}
