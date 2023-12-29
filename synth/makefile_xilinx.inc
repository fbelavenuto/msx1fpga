
# Xilinx

# Create pld file
pld: ${DESIGN}.pld

# bitstream : Creates device bitstream
bitstream: ${DESIGN}.bit

# translate: Stops after full design elaboration for analysis and floorplanning prior to place and route step
translate: ${DESIGN}.ngd

# Following executes the ISE run

# Produces: .ngc .nfr .syr _top.lso .xrpt _xmsgs/ xst/
${DESIGN}.ngc: ${DESIGN}.xst
	mkdir -p xst/projnav.tmp
	xst -intstyle ise -ifn $< -ofn ${DESIGN}.syr

# Produces: _ngo/ _xmsgs/ .bld .ngd _ngdbuild.xrpt xlnx_auto_0_xdb/
${DESIGN}.ngd: ${DESIGN}.ngc ${UCF_FILE}
	ngdbuild -intstyle ise -dd _ngo -sd ipcore_dir -nt timestamp -uc ${UCF_FILE} -p ${DEVICE_NAME}-${DEVICE_PACKAGE} ${DESIGN}.ngc $@

# Produces: _xmsgs/ .pcf _map.map _map.mrp _map.ncd _map.ngm _summary.xml _top_map.xrpt _usage.xml
${DESIGN}_map.ncd: ${DESIGN}.ngd
	map -intstyle ise -w -ol high -mt 2 -p ${DEVICE_NAME}-${DEVICE_PACKAGE}-${DEVICE_SPEED} -logic_opt off -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -ir off -pr off -lc off -power off -o $@ $? ${DESIGN}.pcf

# Produces: _xmsgs/ par_usage_statistics.html .ncd .pad .par .ptwx .xpi _pad.csv _pad.txt _top_par.xrpt .unroutes
${DESIGN}.ncd: ${DESIGN}_map.ncd
	par -intstyle ise -w -ol high -mt 4 $? $@ ${DESIGN}.pcf

# Produces: _xmsgs/ .twr .twx
${DESIGN}.twr: ${DESIGN}.ncd
	trce -intstyle ise -v 3 -s 2 -n 3 -fastpaths -xml ${DESIGN}.twx $? -o $@ ${DESIGN}.pcf

# Produces: _xmsgs/ .bgn .bit .drc _bitgen.xwbt _summary.xml _usage.xml webtalk.log
${DESIGN}.bit: ${DESIGN}.ncd
	bitgen -intstyle ise -f ${DESIGN}.ut $?

$(DESIGN).pld: ${DESIGN}.bit
	bit2bin $? $@

# Clean up all the files from the Vivado run
clean:
	rm -rf _xmsgs/ xst/ _ngo/ xlnx_auto_0_xdb/ iseconfig/ \
	  *.syr *.lso *.xrpt *.bld *.ngd *.map *.mrp *.ncd *.ngm \
	  *.xml *.pad *.par *.ptwx *.xpi *.csv *.txt *.unroutes \
	  *.twr *.twx *.bgn *.bit *.drc *.xwbt *.cmd_log *.html \
	  *.ngr *.pcf *.gise *.ngc *.nfr *.log

# Tar and compress all the files
tar:
	tar -czvf ${DESIGN}.tar.gz *.ipf *.xsl *.prj *.svf *.xise *.xst *.xsvf Makefile
