package com.jiwhiz.mydoctor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.core.env.Environment;

import com.jiwhiz.mydoctor.common.ApplicationProperties;

import lombok.extern.slf4j.Slf4j;

@SpringBootApplication
@EnableConfigurationProperties({ApplicationProperties.class})
@Slf4j
public class MyDoctorApiApplication {

    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(MyDoctorApiApplication.class);
        Environment env = app.run(args).getEnvironment();
        String[] profiles = env.getActiveProfiles().length == 0 ? env.getDefaultProfiles() : env.getActiveProfiles();
        log.info(
            """
            ----------------------------------------------------------
            Application '{}' is running with version {}!
            DB URL:      \t{}
            DB Username: \t{}
            Profile(s):  \t{}
            ----------------------------------------------------------
            """,
            env.getProperty("spring.application.name"),
            env.getProperty("spring.application.version"),
            env.getProperty("spring.datasource.url"),
            env.getProperty("spring.datasource.username"),
            profiles
        );
    }

}
