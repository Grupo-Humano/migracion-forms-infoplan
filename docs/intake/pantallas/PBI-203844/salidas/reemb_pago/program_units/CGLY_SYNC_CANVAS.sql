-- PROGRAM UNIT: CGLY$SYNC_CANVAS
-- Tipo: Procedure
-- ====================================================================

procedure CGLY$SYNC_CANVAS(canvas_is in char,
                      scrollx in number,
                      block_is char) is
canvas_movement number(3);
view_id viewport;

begin

  view_id := find_view(canvas_is);

  canvas_movement := (scrollx *
      (to_number(get_block_property(block_is,CURRENT_RECORD)) -
       to_number(get_block_property(block_is,TOP_RECORD))));

  set_view_property(view_id,POSITION_ON_CANVAS,0,canvas_movement);

end;
