players = ["372116", "379143", "696401"]
for x in players:
    from espncricinfo.player import Player
    print(x)
    p = Player(x)
    print(p.name)
    p.get_career_averages()
    p.get_career_summary()
    p.get_data()
