function copychtogr,chstr,grstr
	grstr.CHGR_BR_ARC = chstr.ch_br_arc
	grstr.CHGR_BR_PIX = chstr.CH_BR_PIX
	grstr.chgr_br_HG_LONLAT_deg_disk   = chstr.ch_br_HG_LONLAT_deg_disk
	grstr.chgr_br_CARR_LONLAT_deg_disk = chstr.ch_br_CARR_LONLAT_deg_disk
	grstr.CHGR_CBR_ARC = chstr.CHC_ARC
	grstr.CHGR_CBR_PIX = chstr.CHC_PIX_DISK
	grstr.CHGR_CBR_DEG = chstr.chc_latlon_deg_disk
	grstr.chgr_cbr_carr_disk = chstr.chc_carr_disk
	grstr.CHGR_LAT_WIDTH_HG_DEG = chstr.CH_LAT_WIDTH_HG_DEG
	grstr.CHGR_LON_WIDTH_HG_DEG = chstr.CH_LON_WIDTH_HG_DEG
	grstr.CHGR_LAT_WIDTH_ARC = chstr.CH_LAT_WIDTH_ARC
	grstr.CHGR_LON_WIDTH_ARC = chstr.CH_LON_WIDTH_ARC
	grstr.CHGR_LAT_WIDTH_PX  = chstr.CH_LAT_WIDTH_PX
	grstr.CHGR_LON_WIDTH_PX  = chstr.CH_LON_WIDTH_PX
	grstr.CHGR_LAT_WIDTH_CARR_DEG  = chstr.CH_LAT_WIDTH_CARR_DEG
	grstr.CHGR_LON_WIDTH_CARR_DEG  = chstr.CH_LON_WIDTH_CARR_DEG
	grstr.CHGR_AREA_PIX = chstr.ch_area_px_disk
	grstr.CHGR_AREA_Deg2 = chstr.CH_AREA_Deg2
	grstr.CHGR_AREA_MM = chstr.CH_AREA_MM
return,grstr
end
