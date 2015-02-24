create or replace PACKAGE BODY XXDMA_PO_SPEND_REP_PKG
AS
 PROCEDURE xxdma_po_get_spend_prc (
      P_SPEND_PERIOD_FROM   IN              VARCHAR2 DEFAULT NULL,
      P_SPEND_PERIOD_TO     IN              VARCHAR2 DEFAULT NULL,
      P_OPERATING_UNIT      IN              VARCHAR2 DEFAULT 'All',
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_return_msg          OUT NOCOPY      VARCHAR2,
      p_po_spend_tab        OUT NOCOPY      XXDMA_PO_SPEND_TAB
   )
   IS

   CURSOR cur_po_spend (P1_SPEND_PERIOD_FROM VARCHAR2, P1_SPEND_PERIOD_TO VARCHAR2, P1_OPERATING_UNIT VARCHAR2)
   IS
      SELECT SUM(SPEND_VALUE) SPEND_VALUE
	        , SPEND_CATEGORY
            , P1_SPEND_PERIOD_FROM         SPEND_PERIOD_FROM
			, P1_SPEND_PERIOD_TO           SPEND_PERIOD_TO
			, NVL(P1_OPERATING_UNIT,'All') OPERATING_UNIT
      FROM
        (SELECT
            poh.creation_date SPEND_PERIOD_FROM,
            poh.creation_date SPEND_PERIOD_TO,
            msib.organization_id,
            msib.inventory_item_id,
           (SELECT SUM (pol.unit_price * pol.quantity)
            FROM po_lines_all
            WHERE 1 = 1
            AND po_header_id = poh.po_header_id) SPEND_VALUE,
           (SELECT mc.segment1
            FROM mtl_categories_v mc
            WHERE 1 = 1
            AND mc.category_id = pol.category_id) SPEND_CATEGORY,
           (SELECT name 
            FROM hr_operating_units
            WHERE organization_id= poh.org_id ) OPERATING_UNIT      
        FROM
           po_lines_all pol, 
           po_vendors pv, 
           po_line_locations_all poll, 
           po_headers_all poh, 
           mtl_system_items_b msib 
        WHERE
           pv.vendor_id = poh.vendor_id and 
           poh.po_header_id=pol.po_header_id and 
           poll.po_header_id = poh.po_header_id and 
           poll.po_line_id=pol.po_line_id and 
          (msib.organization_id = poll.ship_to_organization_id or 
           msib.inventory_item_id is null) and 
           msib.inventory_item_id(+) = pol.item_id
           AND poh.creation_date BETWEEN nvl(to_date(P1_SPEND_PERIOD_FROM,'YYYY/MM/DD HH24:MI:SS'),poh.creation_date)
           AND nvl(to_date(P1_SPEND_PERIOD_TO, 'YYYY/MM/DD HH24:MI:SS'),poh.creation_date) 
           AND poh.authorization_status = 'APPROVED' 
           AND poh.type_lookup_code    = 'STANDARD'
		 )
      WHERE operating_unit = NVL(P1_OPERATING_UNIT, operating_unit)
      GROUP BY SPEND_CATEGORY;

	  i      NUMBER := 0;
	  e_exit  EXCEPTION;
	  l_po_spend_obj XXDMA_PO_SPEND_OBJ := XXDMA_PO_SPEND_OBJ(NULL,NULL,NULL,NULL,NULL);

   BEGIN
 
   x_return_status:='S';
   p_po_spend_tab := XXDMA_PO_SPEND_TAB();

     FOR rec_po_spend IN cur_po_spend (P_SPEND_PERIOD_FROM,P_SPEND_PERIOD_TO,P_OPERATING_UNIT)
		  LOOP
		  p_po_spend_tab.EXTEND;
		  i:=i+1;
		  l_po_spend_obj.SPENDVALUE         := rec_po_spend.SPEND_VALUE;
		  l_po_spend_obj.SPENDCATEGORY      := rec_po_spend.SPEND_CATEGORY;
		  l_po_spend_obj.SPEND_PERIOD_FROM  := to_char(rec_po_spend.SPEND_PERIOD_FROM);
		  l_po_spend_obj.SPEND_PERIOD_TO    := to_char(rec_po_spend.SPEND_PERIOD_TO);
		  l_po_spend_obj.OPERATING_UNIT     := rec_po_spend.OPERATING_UNIT;
		  p_po_spend_tab(i)                 := l_po_spend_obj;
		  END LOOP;

	 IF i=0 THEN

        x_return_msg := 'No records found in the given criteria';
        x_return_status:='E';

        RAISE e_exit;
	 END IF;

   EXCEPTION
     WHEN e_exit THEN
	         i:=i+1;
	         x_return_status:='E';
      dbms_output.put_line('no records');
      WHEN OTHERS
      THEN
		 i:=i+1;
	         x_return_status:='E';
             x_return_msg := 'Error in the program ' ||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

   END xxdma_po_get_spend_prc;

END XXDMA_PO_SPEND_REP_PKG;
/
SHOW ERRORS