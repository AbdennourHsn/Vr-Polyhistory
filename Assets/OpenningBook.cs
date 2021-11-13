using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class OpenningBook : MonoBehaviour
{
    public GameObject join;
    public GameObject cub;
    bool on;
   public void OpenBook( )
    {

        on = true;

        //LeanTween.rotate(this.gameObject,  new Vector3(-177f ,0, 0) , 2) ;

        LeanTween.rotateX(this.gameObject, -177f, 2);
        float A = -180+ Vector3.Angle(Vector3.forward, join.transform.forward);
        LeanTween.rotateAround(this.gameObject ,new Vector3(1,0,0) , A,1) ;
        cub.SetActive(false);

    }

    private void Update()
    {
        if (!on)
        {
            if (Vector3.Angle(Vector3.forward, join.transform.forward) <= 90)
                join.transform.LookAt(new Vector3(this.transform.position.x, cub.transform.position.y, cub.transform.position.z));
            else join.transform.LookAt(new Vector3(this.transform.position.x, cub.transform.position.y, cub.transform.position.z), Vector3.down);

        }

        if (!on && Vector3.Angle(Vector3.forward, join.transform.forward) > 95) OpenBook();
       
    }



}
