FRAME_EVENT_SYSTEMS['draw_on_canvas'] =
lambda do |game, animation, store, frame_event|
  case frame_event['draw_on_canvas']
  when 'stomp_burn_mark'
    image = SPRITE_SHEETS['swordsman']['stomp_burn_mark']['images'].first
    draw_x = (store['x_q8'] >> 8) - 16
    draw_y = (store['y_q8'] >> 8) - 28
    game.canvas.splice image, draw_x, draw_y, :alpha_blend => true#, :mode => :darken
    #game.canvas.render do
    #  image.draw \
    #  (store['x_q8'] >> 8) - 16,
    #  (store['y_q8'] >> 8) - 28,
    #  0, 1, 1#, 0xaaFFFFFF, :multiply
    #end
  when 'shuriken'
    
    image = SPRITE_SHEETS['swordsman']['shuriken']['images'][rand(4)]
    if store['parent_id'] == 2
      blank_image = TexPlay.create_image($window, 16, 16)
      blank_image.splice image, 0, 0#, :alpha_blend => true
      blank_image.each(region: [0,0,16,16]) do |c, x, y|
        c[0], c[2] = c[2], c[0]
      end
      image = blank_image
    end
    draw_x = (store['x_q8'] >> 8) - 10 + rand*4
    draw_y = (store['y_q8'] >> 8) - 10 + rand*4
    game.canvas.splice image, draw_x, draw_y, :alpha_blend => true
  end
  :ok
end