gem 'minigl', '2.4.1'

require 'minigl'

REF_SCREEN_WIDTH = 3840
BASE_TILE_SIZE = 160
SCREEN_COLS = 24
SCREEN_ROWS = 13
MOVE_SPEED = 10
UI_Z_INDEX = 1000
TRANSITION_Z_INDEX = 2000

ITEM_UI_ATTRS = {
  key_0: { icon: :Key, color: 0xdd0000 },
  key_1: { icon: :Key, color: 0x1133ff },
  key_2: { icon: :Key, color: 0xf6ca13 },
  key_3: { icon: :Key, color: 0x009911 },
}.freeze

Vector = MiniGL::Vector
Locl = MiniGL::Localization
