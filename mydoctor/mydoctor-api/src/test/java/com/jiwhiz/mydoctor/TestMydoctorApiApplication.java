package com.jiwhiz.mydoctor;

import org.springframework.boot.SpringApplication;

public class TestMydoctorApiApplication {

    public static void main(String[] args) {
        SpringApplication.from(MyDoctorApiApplication::main).with(TestcontainersConfiguration.class).run(args);
    }

}
