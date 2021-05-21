.PHONY: links
links:
ifeq ("$(wildcard dpi_models)","")
	ln -s ../../.bender/git/checkouts/$(shell basename ../../.bender/git/checkouts/tbtools*)/dpi_models/ .
endif
ifeq ("$(wildcard tb_driver)","")
	ln -s ../../.bender/git/checkouts/$(shell basename ../../.bender/git/checkouts/tbtools*)/tb_driver/ .
endif


.PHONY: clean
clean:
	rm ./dpi_models
	rm ./tb_driver