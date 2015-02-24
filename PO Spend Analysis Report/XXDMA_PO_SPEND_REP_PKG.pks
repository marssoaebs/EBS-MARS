create or replace PACKAGE XXDMA_PO_SPEND_REP_PKG
AS
 g_pkg_name CONSTANT VARCHAR2 (30) := 'XXDMA_PO_SPEND_REP_PKG';

-- =================================================================================================+
-- Package Spec : APPS.XXDMA_PO_SPEND_REP_PKG
-- Procedure :
-- Tables    :
-- Modification History :

-- +==================================================================================================+

 PROCEDURE xxdma_po_get_spend_prc (
      P_SPEND_PERIOD_FROM   IN              VARCHAR2 DEFAULT NULL,
      P_SPEND_PERIOD_TO     IN              VARCHAR2 DEFAULT NULL,
      P_OPERATING_UNIT      IN              VARCHAR2 DEFAULT 'All',
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_return_msg          OUT NOCOPY      VARCHAR2,
      p_po_spend_tab        OUT NOCOPY      XXDMA_PO_SPEND_TAB
   );

END XXDMA_PO_SPEND_REP_PKG;
/
SHOW ERRORS