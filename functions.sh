#!/bin/bash

function ip-address() {

		hostname --ip-address |awk {'print $1'}
		exit
}

function message() {
	var=$($1)
 echo "La direccion ip es "$var

}

message ip-address