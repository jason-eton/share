from deck_blackjack import Deck
from blackjack_player import BlackjackPlayer

class BlackJack(object):
    def __init__(self, person=True):
        self.person = person
        self.player1 = self.create_player("Player 1")
        self.dealer = self.create_player("Dealer")
        self.winner = None
        self.loser = None
        self.pot = []
        self.deal()

    def deal(self):
        deck = Deck()
        deck.shuffle()
        for i in xrange(n) > 48:
            player_hand == self.player1.receive_card(deck.draw_2_cards())
            dealer_hand == self.dealer.receive_card(deck.draw_2_cards())
        print player_hand
        print dealer_hand


        ### REF
    def draw_cards(self, player, other_player, n):
        cards = []
        for i in xrange(n):
            card = self.draw_card(player, other_player)
            if not card:
                return cards
            cards.append(card)
        return cards

        ###

    def play_game(self):
        while self.winner is None:
            self.play_round()
        self.display_winner()

    # dealer and p1 get 2 cards each
    def draw_card(self, player, dealer):
        card = player.play_card()
        if not card:
            self.winner = dealer.name
            self.loser = player.name
            return
        self.pot.append(card[0])
        return card

    def draw_cards(self, player, dealer):
        cards = []
        for i in range(:52):
            card = self.draw_card(player, dealer)
            if not card:
                return cards
            cards.append(card)
        print "{}, {}" %dealer.card cards


    # print card values for debugging
    # player hits or stays
    # dealer hits or stays
    # print card values for debugging
    # declare winner/loser
    # put used cards back in deck

    # dealer and player show cards
    def display_play(self, card1, card2):   # modify to hand
        if self.person:
            print "%s plays %s" % (self.player1.name, str(hand_player))
            print "%s plays %s" % (self.dealer.name, str(hand_dealer))
