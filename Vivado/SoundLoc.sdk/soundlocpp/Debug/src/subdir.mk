################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

CC_SRCS += \
../src/main.cc 

C_SRCS += \
../src/AXI_SH_595.c 

CC_DEPS += \
./src/main.d 

OBJS += \
./src/AXI_SH_595.o \
./src/main.o 

C_DEPS += \
./src/AXI_SH_595.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O2 -g3 -I"C:\Users\marco\Desktop\soundloc\soundloc.sdk\soundlocpp\src\Eigen" -c -fpermissive -fmessage-length=0 -MT"$@" -std=c++11 -I../../ledblink_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/%.o: ../src/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O2 -g3 -I"C:\Users\marco\Desktop\soundloc\soundloc.sdk\soundlocpp\src\Eigen" -c -fpermissive -fmessage-length=0 -MT"$@" -std=c++11 -I../../ledblink_bsp/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


