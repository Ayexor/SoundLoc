################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../drivers/SDM_Decimator_v1_0/src/SDM_Decimator.c 

OBJS += \
./drivers/SDM_Decimator_v1_0/src/SDM_Decimator.o 

C_DEPS += \
./drivers/SDM_Decimator_v1_0/src/SDM_Decimator.d 


# Each subdirectory must supply rules for building sources it contributes
drivers/SDM_Decimator_v1_0/src/%.o: ../drivers/SDM_Decimator_v1_0/src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O2 -g3 -c -fmessage-length=0 -MT"$@" -I../../soundloc_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


