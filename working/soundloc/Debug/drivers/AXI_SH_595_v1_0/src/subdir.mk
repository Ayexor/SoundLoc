################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../drivers/AXI_SH_595_v1_0/src/AXI_SH_595.c 

OBJS += \
./drivers/AXI_SH_595_v1_0/src/AXI_SH_595.o 

C_DEPS += \
./drivers/AXI_SH_595_v1_0/src/AXI_SH_595.d 


# Each subdirectory must supply rules for building sources it contributes
drivers/AXI_SH_595_v1_0/src/%.o: ../drivers/AXI_SH_595_v1_0/src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O2 -g3 -c -fmessage-length=0 -MT"$@" -I../../soundloc_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


