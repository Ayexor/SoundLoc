################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

CC_SRCS += \
../src/leddisplay.cc \
../src/main.cc \
../src/xcorr.cc 

CC_DEPS += \
./src/leddisplay.d \
./src/main.d \
./src/xcorr.d 

OBJS += \
./src/leddisplay.o \
./src/main.o \
./src/xcorr.o 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O2 -g3 -c -fmessage-length=0 -MT"$@" -I../../soundloc_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


