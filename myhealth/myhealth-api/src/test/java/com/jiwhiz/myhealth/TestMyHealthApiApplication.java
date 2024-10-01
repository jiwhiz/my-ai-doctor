package com.jiwhiz.myhealth;

import org.springframework.boot.SpringApplication;

public class TestMyHealthApiApplication {

    public static void main(String[] args) {
        SpringApplication.from(MyHealthApiApplication::main).with(TestcontainersConfiguration.class).run(args);
    }

}
